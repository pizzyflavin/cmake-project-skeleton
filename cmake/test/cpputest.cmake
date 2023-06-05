###################
# CppUTest Module #
###################
#
# This module simplifies the process of adding CppUTest testing support to your build.
#
# You can link against the `CppUTest::CppUTest` and `CppUTest::CppUTestExt` libraries
# to access the dependency in an agnostic manner.
#
# This module also provides a `register_cpputest_test` function to simplify the registration
# of CppUTest test programs. Call this function with the desired test name and the build
# target for the test program. This call can be used with multiple test programs.
#
# Example:
#   register_cpputest_test(Libc.Test libc_tests)

include(${CMAKE_CURRENT_LIST_DIR}/../CPM.cmake)

## Set Default Options
if(NOT CPPUTEST_TEST_OUTPUT_DIR)
    set(CPPUTEST_TEST_OUTPUT_DIR ${CMAKE_BINARY_DIR}/test/ CACHE
        STRING "Location where CppUTest test results should live.")
endif()

######################
# Satisfy Dependency #
######################
#find_package(cpputest QUIET)

#if(NOT cpputest_FOUND)
#    CPMAddPackage(
#        NAME CppUTest
#        GIT_REPOSITORY https://github.com/cpputest/cpputest.git
#        VERSION 4.0
#        GIT_TAG v4.0
#        DOWNLOAD_ONLY YES
#    )
#endif()

# CppUTest
include(FetchContent)
FetchContent_Declare(
    CppUTest
    GIT_REPOSITORY https://github.com/cpputest/cpputest.git
    GIT_TAG        master # or use release tag, eg. v4.0
)
# Set this to ON if you want to have the CppUTests in your project as well.
set(TESTS OFF CACHE BOOL "Switch off CppUTest Test build")
FetchContent_MakeAvailable(CppUTest)



##################################
# Register CppUTest test targets #
##################################

function(register_cpputest_test test_name target)
    add_custom_target(test-${target}
        #COMMAND export CPPUTEST_MESSAGE_OUTPUT=stdout
        COMMAND ${target}
    )

    add_test(NAME ${test_name}
        COMMAND ${target}
    )
endfunction()

