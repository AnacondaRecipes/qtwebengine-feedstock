#!/bin/bash

set -e

# Run smoke test on all Linux architectures
pushd test

# Ensure make can find a compiler.
ln -s ${GXX} g++
export PATH=$PREFIX/bin/xc-avoidance:${PWD}:${PATH}

# Only test that this builds: -d for debug, -Wall for warnings, -Wparser for parser warnings
qmake6 -Wall -Wparser qtwebengine.pro
make

popd
