if(PROJECTVARNAME_TESTING_IS_ENABLED)
    add_executable(MYPROJECT_tests)
    target_include_directories(MYPROJECT_tests PRIVATE .)
    target_link_libraries(MYPROJECT_tests PRIVATE cmocka_dep)
    target_sources(MYPROJECT_tests PRIVATE
        main.c
        test_suite.c
    )
    target_linker_map(MYPROJECT_tests)

    list(APPEND desired_MYPROJECT_tests_flags
        "-Wno-unused-parameter"
    )
    apply_supported_compiler_flags(C MYPROJECT_tests PRIVATE desired_MYPROJECT_tests_flags)

    # This registers teh test and defines testing targets
    register_cmocka_test(MYPROJECT.Test MYPROJECT_tests)
endif(PROJECTVARNAME_TESTING_IS_ENABLED)

