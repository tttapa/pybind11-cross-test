param([String]$config="RelWithDebInfo")

$ErrorActionPreference = "Stop"
try {
    $scriptpath = $MyInvocation.MyCommand.Path
    $dir = Split-Path $scriptpath
    cd $dir

    cmake -S pybind11 -B build/pybind11 `
        -D CMAKE_TOOLCHAIN_FILE="$(pwd)/toolchain-win.cmake" `
        -D BUILD_TESTING=Off -D PYBIND11_NOPYTHON=On `
        -D CMAKE_INSTALL_PREFIX="$(pwd)/staging/pybind11"
    cmake --build build/pybind11 -j --config "$config"
    cmake --install build/pybind11 --config "$config"
} catch {
    throw
}
