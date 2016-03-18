#include <stdarg.h>
#include <stdio.h>

static bool LOGGING = false;

void DebugString ( const char * exp,... )
{
	char s[300];
	va_list argptr;
	int cnt;

	va_start(argptr, exp);
	cnt = vsprintf(s, exp, argptr);
	va_end(argptr);
#ifdef WINDOWS
	char temp[512];
	sprintf(temp,"%s\n",s);
	OutputDebugStringA(temp);
	printf("%s",temp);
	if ( LOGGING )
	{
	static bool first = true;

	FILE *fp;
	if ( first )
		fp = fopen("ASSERTlog.txt","w" );
	else
		fp = fopen("ASSERTlog.txt","a" );
	fputs(temp, fp );
	fclose(fp);
	first = false;
	}
	
#else
	printf("%s",s);
#endif
	
}
#ifdef __APPLE__
#include "TargetConditionals.h"
#endif

void DebugAssert( const char * file, int line, const char *exp )
{
     char str[256];
     sprintf(str,"ASSERT: FILE: %s LINE: %d (%s)",file,line,exp );
	 LOGGING = true;
	 DebugString(str);
	 LOGGING = false;
//	 getch();
#ifdef WINDOWS
     __debugbreak();
#else
#if ( TARGET_IPHONE_SIMULATOR )
	__asm ("int $3");
#else
    //asm("trap");
#endif    
#endif
    

}
