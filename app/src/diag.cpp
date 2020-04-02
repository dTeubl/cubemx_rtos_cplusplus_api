
// #include "main.h"

#include "diag.hpp"


#include <sstream>
#include <string>

template<std::size_t N, class T>
constexpr std::size_t countof(T(&)[N]) { return N; }

int some_array[1024];
static_assert(countof(some_array) == 1024, "wrong size");


s_msg appDiag ( void ){
    s_msg ms;
    auto veson{__cplusplus};

    std::string str{"Hello RTOS, cpp: " + std::to_string(veson) + "\n"};

    // Blink just to show satatus

    std::size_t length = str.copy(ms.msg,50);
    ms.msg[length]='\0';
    ms.len = str.size();

    return ms;
}



