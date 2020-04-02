#ifndef __DIAG_H__
#define __DIAG_H__


#include <stdio.h>
#include <string.h>
//#include "main.h"

#include <cstring>

typedef struct ttt{
    char msg[50];
    //const char *msg;
    unsigned int len;
} s_msg;

class Message {
    Message(): len{0} {}
    Message(const char* );
    char * getMsg();
    std::size_t  getlen();

    private:
        std::size_t len{0};
        const char* msg; 
};

extern "C" s_msg appDiag ( void );


#endif
