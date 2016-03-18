#ifndef __DEBUG_FUNCS_H
#define __DEBUG_FUNCS_H

#ifndef NULL
#define NULL 0
#endif
#define ASSERT( exp ) if ( !(exp) ) DebugAssert( __FILE__, __LINE__, #exp );
void DebugAssert( const char * file, int line, const char *exp );
void DebugString ( const char * exp,... );



#endif

