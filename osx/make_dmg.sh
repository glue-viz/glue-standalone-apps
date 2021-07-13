#!/bin/bash

rm -rf dist/start_glue
python osx/fix_app_qt_folder_names_for_codesign.py dist/glue.app
codesign -s - --force --all-architectures --timestamp --deep dist/glue.app
dist/glue.app/Contents/MacOS/start_glue --test
hdiutil create -volname "Glue" -srcfolder dist -ov -format UDZO dist/glue.dmg
rm -rf dist/glue.app
