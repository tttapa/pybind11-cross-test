cmake_minimum_required(VERSION 3.18)
project(pybind11-project VERSION 0.2.0)

set(PYBIND11_FINDPYTHON On)
find_package(pybind11 REQUIRED)

pybind11_add_module(_add_module MODULE "add_module.cpp")
target_compile_definitions(_add_module PRIVATE
    MODULE_NAME=$<TARGET_FILE_BASE_NAME:_add_module>
    VERSION_INFO="${PROJECT_VERSION}"
)
