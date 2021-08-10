################################
# Native Toolchain File: gcc-8 #
################################

set(CMAKE_C_COMPILER    gcc-8)
set(CMAKE_CXX_COMPILER  g++-8)

if(NOT (${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Darwin"))
    # gcc-ar-8 doesn't successfully find the linker plugin on Darwin
    set(CMAKE_AR            gcc-ar-8)
endif()

