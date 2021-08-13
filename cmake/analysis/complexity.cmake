#####################
# Complexity Module #
#####################

find_program(LIZARD lizard)

if(LIZARD)
    if(NOT LIZARD_DIRS)
        set(LIZARD_DIRS src test CACHE
            STRING "CMake list of directories to analyze with lizard.")
    endif()

    if(LIZARD_ADDITIONAL_DIRS)
        list(APPEND LIZARD_DIRS "${LIZARD_ADDITIONAL_DIRS}")
    endif()

    if(NOT LIZARD_LENGTH_LIMIT)
        set(LIZARD_LENGTH_LIMIT 75 CACHE
            STRING "The maximum length of a function (in lines) before a failure is triggered.")
    endif()

    if(NOT LIZARD_CCN_LIMIT)
        set(LIZARD_CCN_LIMIT 10 CACHE
            STRING "The maximum CCN of a function before a failure is triggered.")
    endif()

    if(NOT LIZARD_ARG_LIMIT)
        set(LIZARD_ARG_LIMIT 6 CACHE
            STRING "The maximum number of function arguments before a failure is triggered.")
    endif()

    set(LIZARD_BASE_ARGS
        --length ${LIZARD_LENGTH_LIMIT} # fail when functions longer than this
        --CCN ${LIZARD_CCN_LIMIT}       # fail over this CCN
        --arguments ${LIZARD_ARG_LIMIT} # fail this arg count
    )

    add_custom_target(complexity
        COMMAND ${LIZARD}
            ${LIZARD_BASE_ARGS}
            -w # Only show warnings
            ${LIZARD_DIRS}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    )

    add_custom_target(complexity-full
        COMMAND ${LIZARD}
            ${LIZARD_BASE_ARGS}
            ${LIZARD_DIRS}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    )

    add_custom_target(complexity-xml
        COMMAND ${LIZARD}
            ${LIZARD_BASE_ARGS}
            --xml # Generate XML output
            ${LIZARD_DIRS}
            # Redirect output to file
            > ${CMAKE_BINARY_DIR}/complexity.xml
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    )
else()
    message("[WARNING] Lizard is not installed. Complexity targets are disabled.")
endif()

