cmake_minimum_required(VERSION 3.17)
project(MYPROJECT
   VERSION 0.1
   DESCRIPTION "MYDESCRIPTION"
   LANGUAGES C CXX ASM)

set_property(GLOBAL PROPERTY C_STANDARD 11)
set_property(GLOBAL PROPERTY CXX_STANDARD 17)

#################
# Build Modules #
#################

# Only use testing if we're not somebody's subproject
if((CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME) OR PROJECTVARNAME_BUILD_TESTING)
    include(CTest)
endif()

# Define and process project options
include(BuildOptions.cmake)

# Dependency manager
include(cmake/CPM.cmake)
# Improved functions for checking comiler/linker flag support
include(cmake/compiler/CheckAndApplyFlags.cmake)
# Adds a function for generating a linker map
include(cmake/linker/map.cmake)
# Overrides add_executable so that linker script dependencies are registered automatically
include(cmake/linker/AddExecutableWithLinkerScriptDep.cmake)
# Provides functions to convert ELF files into .bin and .hex
include(cmake/Conversions.cmake)

include(cmake/format/clang-format.cmake)
include(Packaging.cmake)


##################
# Compiler Flags #
##################

# If we're not a subproject, globally apply our warning flags
if(CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
  add_compile_options(-Wall -Wextra)
endif()

# Set default flags
check_c_compiler_flag("-Wno-unknown-pragmas" _Wno_unkonwn_pragmas)
if(_Wno_unknown_pragmas)
    add_compile_options("-Wno-unknown-pragmas")
endif()

if(ENABLE_COVERAGE)
    include(cmake/CodeCoverage.cmake)
    append_coverage_compiler_flags()
endif()

#####################
# CMocka Dependency #
#####################

if(PROJECTVARNAME_TESTING_IS_ENABLED)
    find_package(cmocka QUIET)

    if(NOT cmocka_FOUND)
      CPMAddPackage(
        NAME cmocka
        GIT_REPOSITORY https://git.cryptomilk.org/projects/cmocka.git/
        VERSION 1.1.5
        GIT_TAG cmocka-1.1.5
        OPTIONS
          "WITH_EXAMPLES OFF"
          "CMAKE_BUILD_TYPE DEBUG"
      )

      # Maintain build compatibility between find_package and CMakeLists.txt variants.
      set(CMOCKA_LIBRARIES cmocka)
    endif()
endif()

##########################
# Enable Static Analysis #
##########################

find_program(CPPCHECK cppcheck)
if(CPPCHECK)
    set(CPPCHECK_DEFAULT_ARGS
        ${CPPCHECK} --quiet --enable=style --force
        # Include directories
        -I ${CMAKE_CURRENT_LIST_DIR}/include
    )

    if(BUILD_WITH_STATIC_ANALYSIS)
        set(CMAKE_C_CPPCHECK ${CPPCHECK_DEFAULT_ARGS})
    endif()

    add_custom_target(cppcheck
        COMMAND ${CPPCHECK_DEFAULT_ARGS}
            # Source directories
            ${CMAKE_CURRENT_LIST_DIR}/src/ ${CMAKE_CURRENT_LIST_DIR}/target/
    )

    add_custom_target(cppcheck-xml
        COMMAND ${CPPCHECK_DEFAULT_ARGS}
            # Enable XML output
            --xml --xml-version=2
            # Source directories
            ${CMAKE_CURRENT_LIST_DIR}/src/ ${CMAKE_CURRENT_LIST_DIR}/target/
            # Redirect to file
            2>${CMAKE_BINARY_DIR}/cppcheck.xml
    )
endif()

find_program(CLANG_TIDY clang-tidy)
if(CLANG_TIDY)
    if(BUILD_WITH_STATIC_ANALYSIS)
        set(CMAKE_C_CLANG_TIDY ${CLANG_TIDY})
    endif()

    add_custom_target(tidy
        COMMAND tools/clang-tidy.sh ${CMAKE_BINARY_DIR}
            # Directories to include in analysis
            "src,test"
            # File types to include in analysis
            "*.c,*.cpp"
        WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
    )
endif()


#######################
# Process Source Tree #
#######################

add_subdirectory(src)

#####################
# Process Test Tree #
#####################

add_subdirectory(test)

###################
# Tooling Targets #
###################

find_program(DOXYGEN doxygen)
if(DOXYGEN)
    add_custom_target(libc-docs
        COMMAND ${DOXYGEN} docs/Doxyfile
        WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
    )
    # This property will remove a directory, while add_custom_target BYPRODUCTS
    # will not.
    set_target_properties(libc-docs PROPERTIES ADDITIONAL_CLEAN_FILES ${CMAKE_BINARY_DIR}/doc/)
endif()

find_program(LIZARD lizard)
if(LIZARD)
    set(LIZARD_BASE_ARGS
        ${LIZARD}
        --length 75 # fail when functions longer than this
        --CCN 10 # fail over this CCN
        --arguments 10 # fail this arg count
    )

    set(LIZARD_PATHS ${CMAKE_CURRENT_LIST_DIR}/src ${CMAKE_CURRENT_LIST_DIR}/tests)

    add_custom_target(complexity
        COMMAND
        ${LIZARD_BASE_ARGS}
        -w # Only show warnings
        ${LIZARD_PATHS}
    )

    add_custom_target(complexity-full
        COMMAND
        ${LIZARD_BASE_ARGS}
        ${LIZARD_PATHS}
    )

    add_custom_target(complexity-xml
        COMMAND
        ${LIZARD_BASE_ARGS}
        --xml # Generate XML output
        ${LIZARD_PATHS}
        # Redirect output to file
        > ${CMAKE_BINARY_DIR}/complexity.xml
    )
endif()

if(ENABLE_COVERAGE)
    setup_target_for_coverage_gcovr_xml(
        NAME coverage-xml
        EXECUTABLE ctest
        DEPENDENCIES MYPROJECT_tests
    )

    setup_target_for_coverage_gcovr_html(
        NAME coverage-html
        EXECUTABLE ctest
        DEPENDENCIES MYPROJECT_tests
    )

    add_custom_target(coverage
        DEPENDS coverage-xml coverage-html)

endif()

