###########################
# Default Linker Settings #
###########################

include(${CMAKE_CURRENT_LIST_DIR}/../compiler/CheckAndApplyFlags.cmake)


set(desired_common_linker_optimization_flags
    -Wl,-gc-sections # Strip dead symbols for GCC
)

# Only append dead_strip flag if on an Apple system. The flag is only used on
# Apple systems, and it passes the check_linker_flag() test on non-Apple
# systems and causes problems.
if(CMAKE_C_COMPILER_ID STREQUAL "AppleClang" OR CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang")
    set(desired_common_linker_optimization_flags
        ${desired_common_linker_optimization_flags}
        -Wl,-dead_strip # Strip dead symbols for macOS/OS X
    )
endif()

if (CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
    apply_supported_linker_flags_globally(C desired_common_linker_optimization_flags)
    apply_supported_linker_flags_globally(CXX desired_common_linker_optimization_flags)
endif()

