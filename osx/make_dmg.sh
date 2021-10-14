#!/bin/bash

mv dist/glue.app dist/"glue $1.app"
rm -rf dist/start_glue
# python osx/fix_app_qt_folder_names_for_codesign.py dist/"glue $1.app"
# codesign -s - --force --all-architectures --timestamp --deep dist/"glue $1.app"
# dist/glue.app/Contents/MacOS/start_glue --test
hdiutil create -volname "Glue" -srcfolder dist -ov -format UDZO "glue $1.dmg"
rm -rf dist/"glue $1.app"
