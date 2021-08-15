###########################
# Default Linker Settings #
###########################

include(${CMAKE_CURRENT_LIST_DIR}/../compiler/CheckAndApplyFlags.cmake)

set(desired_common_linker_optimization_flags
    -Wl,-dead_strip # Strip dead symbols for macOS/OS X
    -Wl,-gc-sections # Strip dead symbols for GCC
)

if (CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
    apply_supported_linker_flags_globally(C desired_common_linker_optimization_flags)
    apply_supported_linker_flags_globally(CXX desired_common_linker_optimization_flags)
endif()

