# System information
set(CMAKE_SYSTEM_NAME "Linux")
set(CMAKE_SYSTEM_PROCESSOR "aarch64")
set(CMAKE_LIBRARY_ARCHITECTURE aarch64-linux-gnu)
set(CROSS_GNU_TRIPLE "aarch64-linux-gnu" CACHE STRING "The GNU triple of the toolchain to use")

# Search path configuration
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# Compilers
set(CMAKE_C_COMPILER "${CROSS_GNU_TRIPLE}-gcc" CACHE FILEPATH "C compiler")
set(CMAKE_CXX_COMPILER "${CROSS_GNU_TRIPLE}-g++" CACHE FILEPATH "C++ compiler")
