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
# Enable code coverage analysis support target
include(cmake/analysis/coverage.cmake)

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

# Provides cppcheck targets and an option to compile with cppcheck analysis
include(cmake/analysis/cppcheck.cmake)
# Provides clang-tidy targets and an option to compile with clang-tidy analysis
include(cmake/analysis/clang-tidy.cmake)

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

# Provides clang-format build targets
include(cmake/format/clang-format.cmake)
# Provides complexity analysis targets
include(cmake/analysis/complexity.cmake)
# Defines code coverage analysis targets
enable_coverage_targets(MYPROJECT_tests)

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

