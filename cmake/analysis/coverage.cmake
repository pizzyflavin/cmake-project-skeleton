########################
# Code Coverage Module #
########################
#
# This module is a wrapper around CodeCoverage.cmake, simplifying its use and
# auto-creating code coverage build targets.
#
# This module defines an `ENABLE_COVERAGE_ANALYSIS` option, which defaults to OFF.
#   This option is only available when creating a debug build
#
# Include this module at the top of teh build file, before defining any build targets.
# This will ensure that the proper compilation flags are added to the build.
#
# After targets have been defined, the function `enable_coverage_targets` can be invoked.
# Call this function and supply any targets that are to be registered as dependencies for
# the coverage targets.
#
# Example:
#   enable_coverage_targets(libc_tests printf_tests)

include(CMakeDependentOption)

CMAKE_DEPENDENT_OPTION(ENABLE_COVERAGE_ANALYSIS
    "Enable code coverage analysis."
    OFF
    "\"${CMAKE_BUILD_TYPE}\" STREQUAL \"Debug\""
    OFF)

if(ENABLE_COVERAGE_ANALYSIS)
    include(${CMAKE_CURRENT_LIST_DIR}/CodeCoverage.cmake)
    append_coverage_compiler_flags()
endif()

function(enable_coverage_targets)
    if(ENABLE_COVERAGE_ANALYSIS)
        setup_target_for_coverage_gcovr_xml(
            NAME coverage-xml
            EXECUTABLE ctest
            DEPENDENCIES ${ARGN}
        )

        setup_target_for_coverage_gcovr_html(
            NAME coverage-html
            EXECUTABLE ctest
            DEPENDENCIES ${ARGN}
        )

        add_custom_target(coverage
            DEPENDS coverage-xml coverage-html
        )
    endif()
endfunction()

