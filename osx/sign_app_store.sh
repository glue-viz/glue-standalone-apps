#!/bin/bash
#
# Sign a glue .app bundle for submission to the Mac App Store.
#
# Usage:
#   osx/sign_app_store.sh <app_path> <signing_identity> <team_id> <bundle_id>
#
#   app_path         Path to the built .app (e.g. "dist/glue main.app")
#   signing_identity The "Apple Distribution" / "3rd Party Mac Developer
#                    Application" identity to sign the app and its nested code
#                    with (common name or SHA-1 of the certificate).
#   team_id          Apple Developer Team ID, used to build the application
#                    group identifier.
#   bundle_id        Bundle identifier of the main app
#                    (io.gluesolutions.glueviz).
#
# Unlike the Developer ID / DMG path we deliberately do NOT use `codesign
# --deep`: the App Store requires each nested bundle to carry its own correct
# entitlements, and --deep would re-sign the QtWebEngineProcess helper with the
# main app's entitlements. Instead we sign inner-to-outer by hand:
#
#   1. every nested Mach-O (.dylib / .so) with no entitlements
#   2. the QtWebEngineProcess.app helper, after giving it a unique bundle
#      identifier, with the helper entitlements
#   3. every .framework
#   4. the outer .app with the sandbox entitlements
#
# Re-identifying the helper is what fixes the "bundle identifier is already in
# use" validation error: PyQtWebEngine ships QtWebEngineProcess.app with the
# hardcoded id org.qt-project.Qt.QtWebEngineCore, which the App Store validator
# rejects because it is not unique within the package. Qt locates the helper by
# path, not by identifier, so renaming the identifier is safe at runtime.

set -euo pipefail

if [ "$#" -ne 4 ]; then
    echo "usage: $0 <app_path> <signing_identity> <team_id> <bundle_id>" >&2
    exit 2
fi

APP="$1"
IDENTITY="$2"
TEAM_ID="$3"
BUNDLE_ID="$4"

HERE="$(cd "$(dirname "$0")/.." && pwd)"

if [ ! -d "$APP" ]; then
    echo "error: app bundle not found: $APP" >&2
    exit 1
fi

# Materialise the entitlement templates with the real Team ID substituted in.
WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

APP_ENT="$WORKDIR/entitlements-appstore.plist"
HELPER_ENT="$WORKDIR/entitlements-helper.plist"
sed "s/__TEAM_ID__/$TEAM_ID/g" "$HERE/entitlements-appstore.plist" > "$APP_ENT"
sed "s/__TEAM_ID__/$TEAM_ID/g" "$HERE/entitlements-helper.plist" > "$HELPER_ENT"

echo "==> Signing nested libraries (.dylib / .so)"
# -print0/-d '' keeps paths with spaces intact (the app name contains a space).
find "$APP" -type f \( -name '*.dylib' -o -name '*.so' \) -print0 |
    while IFS= read -r -d '' lib; do
        codesign --force --timestamp -s "$IDENTITY" "$lib"
    done

echo "==> Re-identifying and signing the QtWebEngineProcess helper"
while IFS= read -r -d '' helper; do
    echo "    helper: $helper"
    /usr/libexec/PlistBuddy \
        -c "Set :CFBundleIdentifier $BUNDLE_ID.QtWebEngineProcess" \
        "$helper/Contents/Info.plist"
    codesign --force --timestamp \
        --entitlements "$HELPER_ENT" \
        -s "$IDENTITY" "$helper"
done < <(find "$APP" -type d -name 'QtWebEngineProcess.app' -print0)

echo "==> Signing frameworks"
# Frameworks must be signed after their contents (the helper lives inside
# QtWebEngineCore.framework), so this runs after the helper step above.
find "$APP" -type d -name '*.framework' -print0 |
    while IFS= read -r -d '' fw; do
        codesign --force --timestamp -s "$IDENTITY" "$fw"
    done

echo "==> Signing the main application bundle"
codesign --force --timestamp \
    --entitlements "$APP_ENT" \
    -s "$IDENTITY" "$APP"

echo "==> Verifying signature"
codesign --verify --deep --strict --verbose=2 "$APP"

echo "==> Done"
