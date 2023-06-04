#include "CppUTest/TestHarness.h"

extern "C" {
    //#include "component.h"
}

TEST_GROUP(FirstTestGroup)
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

TEST(FirstTestGroup, FirstTest)
{
    FAIL("Fail me!");
}


