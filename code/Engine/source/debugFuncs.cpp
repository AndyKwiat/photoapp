#include<stdio.h>

bool assert_handler( char const *str, char const *file, int line )
{
	printf("ASSERT FAIL: %s, FILE %s,%d",str,file,line);
	return true;
}

bool debugBreak()
{
#ifdef WIN32
	__debugbreak();
#else
    __builtin_trap(); // ios/mac
#endif
    return false;
}