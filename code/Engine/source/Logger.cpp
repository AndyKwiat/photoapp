#include<stdio.h>
#include "Logger.h"
#include "XString.h"

namespace Logger
{
    void writeLog( const char *str )
    {
        printf("%s",str);
    }
    
    void Error( const XString &errorString )
    {
        writeLog( errorString.c_str());
    }
}
