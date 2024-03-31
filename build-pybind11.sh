#!/usr/bin/env bash
cd "$( dirname "${BASH_SOURCE[0]}" )"

set -ex

cmake -S pybind11 -B build/pybind11 \
    --toolchain="$PWD/toolchain.cmake" \
    -D BUILD_TESTING=Off -D PYBIND11_NOPYTHON=On \
    -D CMAKE_INSTALL_PREFIX="$PWD/staging/pybind11/usr/local"
cmake --build build/pybind11
cmake --install build/pybind11
