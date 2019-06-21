#!/bin/bash

# Need files generated by templated docker builder. Not easily available until ngc is built
# with rapidsdevtool.sh
# As a war cd to existing build-... directory and mount it by passing:
# docker run -w $PWD -v $PWD:$PWD ...
# Script below copies the files, clones notebooks and runs tests

cp -r /rapids_native/utils "$RAPIDS_DIR/"
cp -r /rapids_native/supportfiles/test.sh "$RAPIDS_DIR/"

cd "${RAPIDS_DIR}" || exit
git clone --branch branch-0.8 https://github.com/rapidsai/notebooks.git notebooks
./test.sh
