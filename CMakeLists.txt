cmake_minimum_required(VERSION 3.17)
project(Project
   VERSION 1.0
   DESCRIPTION "Description"
   LANGUAGES C CXX ASM)

set_property(GLOBAL PROPERTY C_STANDARD 11)

include(cmake/CPM.cmake)

# Only use testing if we're not somebody's subproject!
if((CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME) OR LIBC_BUILD_TESTING)
    include(CTest)
endif()

include(BuildOptions.cmake)
include(cmake/CheckAndApplyFlags.cmake)
include(cmake/Conversions.cmake)
include(cmake/AddExecutableWithLinkerScriptDep.cmake)
include(Packaging.cmake)

if(ENABLE_COVERAGE)
    include(cmake/CodeCoverage.cmake)
    append_coverage_compiler_flags()
endif()

##################
# Compiler Flags #
##################

# If we're not a subproject, globally apply our warning flags
if(CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
  add_compile_options(-Wall -Wextra)
endif()

##################
# Linker Flags   #
##################
function(target_linker_map target)
    check_c_linker_flag("-Wl,-Map,test.map" _map1)
    if("${_map1}")
        set(GEN_MAP_FILE "-Wl,-Map,")
    else()
        check_c_linker_flag("-Wl,-map,test.map" _map2)
        if("${_map2}")
            set(GEN_MAP_FILE "-Wl,-map,")
        else()
            message("[WARNING] ${CMAKE_C_COMPILER_ID} does not have a defined linker map argument.")
            return()
        endif()
    endif()

    get_target_property(map_dir ${target} BINARY_DIR)
    target_link_options(${target} PRIVATE ${GEN_MAP_FILE}${map_dir}/${target}.map)
    set_target_properties(${target} PROPERTIES
        ADDITIONAL_CLEAN_FILES ${target}.map)
endfunction()

#####################
# Printf Dependency #
#####################

CPMAddPackage(
  NAME printf
  GITHUB_REPOSITORY mpaland/printf
  VERSION 4.0.0
  DOWNLOAD_ONLY
)

add_library(printf INTERFACE)
target_sources(printf INTERFACE ${printf_SOURCE_DIR}/printf.c)
target_include_directories(printf SYSTEM INTERFACE ${printf_SOURCE_DIR})

if(LIBC_TESTING_IS_ENABLED)
  add_executable(printf_tests)
  target_sources(printf_tests PRIVATE ${printf_SOURCE_DIR}/test/test_suite.cpp)
  target_include_directories(printf_tests PRIVATE ${printf_SOURCE_DIR})
  install(FILES ${printf_SOURCE_DIR}/printf.h DESTINATION include)
  set_target_properties(printf_tests PROPERTIES CXX_STANDARD 11)
  target_linker_map(printf_tests)

  # Re-build + execute tests, printing test information to the console instead of the XML file
  add_custom_target(test-printf printf_tests)

  add_test(NAME Printf.Test
    COMMAND printf_tests -s -r junit -o ${CMAKE_BINARY_DIR}/printf_tests.xml
  )
endif()

#######################
# Openlibm Dependency #
#######################

CPMAddPackage(
  NAME openlibm
  GITHUB_REPOSITORY JuliaMath/openlibm
  VERSION 0.7.0
  DOWNLOAD_ONLY
)

add_library(openlibm INTERFACE)
target_include_directories(openlibm SYSTEM INTERFACE
   ${openlibm_SOURCE_DIR}/src
   ${openlibm_SOURCE_DIR}/include
)

install(DIRECTORY ${openlibm_SOURCE_DIR}/include/ DESTINATION include)
install(DIRECTORY ${openlibm_SOURCE_DIR}/src DESTINATION include FILES_MATCHING PATTERN "*.h")

#####################
# CMocka Dependency #
#####################

if(LIBC_TESTING_IS_ENABLED)
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
        WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
    )
endif()


#######################
# Process Source Tree #
#######################

add_subdirectory(arch/${CMAKE_SYSTEM_PROCESSOR})
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

find_program(CLANG_FORMAT clang-format)
if(CLANG_FORMAT)
    add_custom_target(format
        COMMAND tools/format.sh
        WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
    )

    add_custom_target(format-patch
        COMMAND tools/format-patch.sh
        WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
    )
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
        DEPENDENCIES libc_tests printf_tests
    )

    setup_target_for_coverage_gcovr_html(
        NAME coverage-html
        EXECUTABLE ctest
        DEPENDENCIES libc_tests printf_tests
    )

    add_custom_target(coverage
        DEPENDS coverage-xml coverage-html)

endif()

