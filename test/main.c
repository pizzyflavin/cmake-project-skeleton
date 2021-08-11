/*
 * Copyright © YEAR ORGANIZATION
 * See LICENSE file for details.
 */

// CMocka needs these
// clang-format off
#include <setjmp.h>
#include <stdarg.h>
#include <stddef.h>
#include <cmocka.h>
// clang-format on

#include "tests.h"

int main(void)
{
    int overall_result = 0;

    // Generate JUnit results
    cmocka_set_message_output(CM_OUTPUT_XML);

    overall_result = test_suite();

    return overall_result;
}

