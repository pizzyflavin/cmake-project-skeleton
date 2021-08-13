#####################
# Clang-tidy Module #
#####################
#
# This module provides both a `tidy` target and an option to enable building
# the project with clang-tidy analysis.
#
# To enable clang-tidy output during the build process, set the
# "BUILD_WITH_CLANG_TIDY_ANALYSIS option to "ON".
#
# You can control the behavior of clang-tidy by setting the following variables
# before including this module:
#   CLANG_TIDY_DIRS - CMake list of directories to include in clang-tidy analysis
#       (By default, the src and test directories are included)
#   CLANG_TIDY_FILETYPES - CMake list of file types to include in clang-tidy analysis,
#       specified as globs (e.g.: "*.c")
#       (By default, we analyze *.c and *.cpp files)
#
# To OVERRIDE the default directories or file types, set the variables above.
#
# To ADD to the default directories or filetypes, set the ADDITIONAL variables below:
#   CLANG_TIDY_ADDITIONAL_DIRS
#   CLANG_TIDY_ADDITIONAL_FILETYPES
#
# To supply additional arguments to clang-tidy, populate the CLANG_TIDY_ADDITIONAL_OPTIONS
# variable. This sould be a CMake list of flags and values. They will be directly
# forwarded to the clang-tidy command.
#   Example:
#       set(CLANG_TIDY_ADDITIONAL_OPTIONS --fix)
#       include(cmake/analysis/clang-tidy.cmake)

find_program(CLANG_TIDY clang-tidy)

if(CLANG_TIDY)
    option(BUILD_WITH_CLANG_TIDY_ANALYSIS
        "Compile the project with clang-tidy support."
        OFF)

    if( BUILD_WITH_CLANG_TIDY_ANALYSIS)
        set(CMAKE_C_CLANG_TIDY ${CLANG_TIDY})
        set(CMAKE_CXX_CLANG_TIDY ${CLANG_TIDY})
    endif()

    #### Supply Argument Defaults
    if(NOT CLANG_TIDY_DIRS)
        set(CLANG_TIDY_DIRS src test CACHE
            STRING "CMake list of directories to analyze with clang-tidy.")
    endif()

    if(NOT CLANG_TIDY_FILETYPES)
        set(CLANG_TIDY_FILETYPES "*.c" "*.cpp" CACHE
            STRING "CMAKE list of file types to analyze using clang-tidy.")
    endif()

    if(CLANG_TIDY_ADDITIONAL_DIRS)
        list(APPEND CLANG_TIDY_DIRS ${CLANG_TIDY_ADDITIONAL_DIRS})
    endif()

    if(CLANG_TIDY_ADDITIONAL_FILETYPES)
        list(APPEND CLANG_TIDY_FILETYPES ${CLANG_TIDY_ADDITIONAL_FILETYPES})
    endif()

    ### Convert variables into script format
    string(REPLACE ";" "," CLANG_TIDY_DIRS_ARG "${CLANG_TIDY_DIRS}")
    string(REPLACE ";" "," CLANG_TIDY_FILETYPES_ARG "${CLANG_TIDY_FILETYPES}")

    set(clang_tidy_args
        ${CLANG_TIDY_DIRS_ARG}
        ${CLANG_TIDY_FILETYPES_ARG}
        ${CLANG_TIDY_ADDITIONAL_OPTIONS}
    )

    add_custom_target(tidy
        COMMAND ${CMAKE_CURRENT_LIST_DIR}/clang-tidy.sh ${CMAKE_BINARY_DIR}
            ${clang_tidy_args}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    )
else()
    message("[WARNING] Clang-tidy is not installed. Clang-tidy targets are disabled.")
endif()

