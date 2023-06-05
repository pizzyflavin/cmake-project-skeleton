if(PROJECTVARNAME_TESTING_IS_ENABLED)
    add_executable(example_tests)

    target_include_directories(example_tests PRIVATE .)
    target_link_libraries(example_tests PRIVATE
        example_lib
        CppUTest::CppUTest
        CppUTest::CppUTestExt
    )
    target_linker_map(example_tests)
    target_sources(example_tests PRIVATE
        main.cpp
        example_tests.cpp
    )

    list(APPEND desired_example_tests_flags
        "-Wno-old-style-cast"
        "-Wno-unused-parameter"
    )
    apply_supported_compiler_flags(CXX example_tests PRIVATE desired_example_tests_flags)

    register_cpputest_test(Example.Test example_tests)

endif(PROJECTVARNAME_TESTING_IS_ENABLED)

