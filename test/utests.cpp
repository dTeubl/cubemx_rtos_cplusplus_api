#include <gtest/gtest.h>
#include <iostream>

#include "diag.hpp"


GTEST_TEST(UseLessCase, Useless){

    s_msg ms = appDiag();
    EXPECT_EQ(std::strlen(ms.msg),ms.len) << "This two should be the same size!" ;
}


int main(int argc, char **argv) {
        ::testing::InitGoogleTest(&argc, argv); 
            return RUN_ALL_TESTS();
}



