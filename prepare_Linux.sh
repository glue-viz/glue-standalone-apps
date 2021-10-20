#!/bin/bash -xe

pip install staticx
staticx dist/glue dist/"glue-$1"
chmod +x dist/"glue-$1"
rm dist/glue
