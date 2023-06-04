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
# Enable code sanitizer build support
include(cmake/analysis/sanitizers.cmake)

# Enable CMocka support if testing is enabled
if(PROJECTVARNAME_TESTING_IS_ENABLED)
    include(cmake/test/cpputest.cmake)
endif()

# Specifies default compiler flags for the project
include(cmake/compiler/DefaultCompilerSettings.cmake)
# Specifies default linker flags for the project
include(cmake/linker/DefaultLinkerSettings.cmake)

include(Packaging.cmake)

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
# Provides Doxygen documentation generation target
include(cmake/documentation/doxygen.cmake)

