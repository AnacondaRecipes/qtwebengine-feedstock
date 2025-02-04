#!/bin/bash

set -e

if [[ $(uname -m) == "x86_64" ]]; then
  echo "[WARN] Skipping smoke test!"
else
  cd test
  ln -s ${GXX} g++
  export PATH=$PREFIX/bin/xc-avoidance:${PWD}:${PATH}
  # Only test that this builds
  qmake6 qtwebengine.pro
  make
fi
