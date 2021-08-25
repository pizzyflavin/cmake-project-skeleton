###################
# CppCheck Module #
###################
#
# This module provides `cppcheck` and `cppcheck-xml` targets, as well as an option to
# enable building the project with cppcheck analysis.
#
# To enable cppcheck output during teh build process, set the
# `BUILD_WITH_CPPCHECK_ANALYSIS` option to "ON"
#
# You can control the behavior of cppcheck by setting teh following variables before you
# include this module:
#   CPPCHECK_ENABLE_CHECKS - Passed to the --enable= argument
#       (By default, "style" is used)
#   CPPCHECK_DIRS - CMake list of directories to include in cppcheck analysis
#       (By default, the src and test directories are included)
#   CPPCHECK_INCLUDE_DIRS - CMake list of directories to pass as include arguments to
#       CppCheck
#       (By default, no include directories are specified)
#   CPPCHECK_EXCLUDES - CMake list of directories of files to exclude from analysis.
#       (By default, no excludes are specified)
#
# To OVERRIDE the default values, set the variables above.
#
# To ADD ADDITIONAL directories or files, set the variable below:
#   CPPCHECK_ADDITIONAL_DIRS

find_program(CPPCHECK cppcheck)

if(CPPCHECK)

    if(NOT CPPCHECK_ENABLE_CHECKS)
        set(CPPCHECK_ENABLE_CHECKS style CACHE
            STRING "Value to pass to the CppCheck --enable= flag")
    endif()

    if(CPPCHECK_INCLUDE_DIRS)
        foreach(dir ${CPPCHECK_INCLUDE_DIRS})
            list(APPEND CPPCHECK_INCLUDE_DIRS_ARG -I ${dir})
        endforeach()
    endif()

    if(CPPCHECK_EXCLUDES)
        foreach(exclude ${CPPCHECK_EXCLUDES})
            list(APPEND CPPCHECK_EXCLUDE_ARG -i ${exclude})
        endforeach()
    endif()

    ### Custom Rules
    if(NOT CPPCHECK_CUSTOM_RULES)
        set(CPPCHECK_CUSTOM_RULES
                ${CMAKE_CURRENT_LIST_DIR}/cppcheck-rules/CollapsibleIfStatements/rule.xml
                ${CMAKE_CURRENT_LIST_DIR}/cppcheck-rules/EmptyElseBlock/rule.xml
                ${CMAKE_CURRENT_LIST_DIR}/cppcheck-rules/EmptyDoWhileStatement/rule.xml
                ${CMAKE_CURRENT_LIST_DIR}/cppcheck-rules/EmptyForStatement/rule.xml
                ${CMAKE_CURRENT_LIST_DIR}/cppcheck-rules/EmptyIfStatement/rule.xml
                ${CMAKE_CURRENT_LIST_DIR}/cppcheck-rules/EmptySwitchStatement/rule.xml
                ${CMAKE_CURRENT_LIST_DIR}/cppcheck-rules/ForLoopShouldBeWhileLoop/rule.xml
                ${CMAKE_CURRENT_LIST_DIR}/cppcheck-rules/InvertedLogic/rule.xml
                ${CMAKE_CURRENT_LIST_DIR}/cppcheck-rules/MultipleUnaryOperator/rule.xml
                ${CMAKE_CURRENT_LIST_DIR}/cppcheck-rules/RedundantConditionalOperator/rule.xml
                ${CMAKE_CURRENT_LIST_DIR}/cppcheck-rules/RedundantIfStatement/rule.xml
                ${CMAKE_CURRENT_LIST_DIR}/cppcheck-rules/UnnecessaryElseStatement/rule.xml
            CACHE STRING "Custom rule files to use with CppCheck")
    endif()

    if(CPPCHECK_ADDITIONAL_CUSTOM_RULES)
        list(APPEND CPPCHECK_CUSTOM_RULES ${CPPCHECK_ADDITIONAL_CUSTOM_RULES})
    endif()

    foreach(rule ${CPPCHECK_CUSTOM_RULES})
        list(APPEND CPPCHECK_CUSTOM_RULES_ARG --rule-file=${rule})
    endforeach()

    ### Static analysis build option
    option(BUILD_WITH_CPPCHECK_ANALYSIS
        "Compile the project with cppcheck support."
        OFF)

    if(BUILD_WITH_CPPCHECK_ANALYSIS)
        set(CMAKE_C_CPPCHECK ${CPPCHECK})
        set(CMAKE_CXX_CPPCHECK ${CPPCHECK})
    endif()

    ### Supply argument defaults for targets
    if(NOT CPPCHECK_DIRS)
        set(CPPCHECK_DIRS src test CACHE
            STRING "CMake list of directories to analyze with cppcheck.")
    endif()

    if(CPPCHECK_ADDITIONAL_DIRS)
        list(APPEND CPPCHECK_DIRS ${CPPCHECK_ADDITIONAL_DIRS})
    endif()


    # With CppCheck, default arguments are shared between the analysis-during-build
    # configuration and with the cppcheck build targets
    set(CPPCHECK_DEFAULT_ARGS
        --quiet --enable=${CPPCHECK_ENABLE_CHECKS} --force
        # Include directories
        ${CPPCHECK_INCLUDE_DIRS_ARG}
        ${CPPCHECK_EXCLUDE_ARG}
        ${CPPCHECK_CUSTOM_RULES_ARG}
    )


    add_custom_target(cppcheck
        COMMAND ${CPPCHECK}
            ${CPPCHECK_DEFAULT_ARGS}
            # Source directories
            ${CPPCHECK_DIRS}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    )

    add_custom_target(cppcheck-xml
        COMMAND ${CPPCHECK}
            ${CPPCHECK_DEFAULT_ARGS}
            # Enable XML output
            --xml --xml-version=2
            # Source directories
            ${CPPCHECK_DIRS}
            # Redirect to file
            2>${CMAKE_BINARY_DIR}/cppcheck.xml
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    )
else()
    message("[WARNING] CppCheck is not installed. CppCheck targets are disabled.")
endif()

