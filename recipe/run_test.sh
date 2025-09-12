#!/bin/bash

set -e

# Run smoke test on all Linux architectures
pushd test

# Ensure make can find a compiler.
ln -s ${GXX} g++
export PATH=${PWD}:${PATH}

if [[ "${target_platform}" == osx-* ]]; then
    # Used to force our sysroot as the SDK instead of trying to detect one with xcrun.
    export QT_MAC_SDK_NO_VERSION_CHECK=1
fi

# Only test that this builds: -d for debug, -Wall for warnings, -Wparser for parser warnings
qmake6 -Wall -Wparser qtwebengine.pro
make

popd
