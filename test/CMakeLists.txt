if(PROJECTVARNAME_TESTING_IS_ENABLED)
    add_executable(example_tests)

    target_include_directories(example_tests PRIVATE .)
    target_link_libraries(example_tests PRIVATE
        CppUTest::CppUTest
        CppUTest::CppUTestExt
    )
    target_linker_map(example_tests)
    target_sources(example_tests PRIVATE
        main.cpp
        example_tests.cpp
    )

    add_test(NAME Example.Test
        COMMAND example_tests
    )

    #target_linker_map(MYPROJECT_tests)

    #list(APPEND desired_MYPROJECT_tests_flags
    #    "-Wno-unused-parameter"
    #)
    #apply_supported_compiler_flags(C MYPROJECT_tests PRIVATE desired_MYPROJECT_tests_flags)

    ## This registers the test and defines testing targets
    ##register_cmocka_test(MYPROJECT.Test MYPROJECT_tests)
endif(PROJECTVARNAME_TESTING_IS_ENABLED)

