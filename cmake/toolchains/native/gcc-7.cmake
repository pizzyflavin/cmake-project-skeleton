################################
# Native Toolchain File: gcc-7 #
################################

set(CMAKE_C_COMPILER    gcc-7)
set(CMAKE_CXX_COMPILER  g++-7)

if(NOT (${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Darwin"))
    # gcc-ar-7 doesn't successfully find the linker plugin on Darwin
    set(CMAKE_AR            gcc-ar-7)
endif()

