#include <CppUTest/TestHarness.h>
#include <CppUTest/UtestMacros.h>

extern "C" {
    #include <example/example.h>
}

TEST_GROUP(ExampleTestGroup)
{
    void setup()
    {
        // setup
    }

    void teardown()
    {
        // cleanup
    }
};

TEST(ExampleTestGroup, ExampleTest1)
{
    int ret_val = ret42();
    CHECK_EQUAL(42, ret_val);
}

