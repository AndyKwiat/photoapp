#ifdef DEBUG
bool debugBreak();
bool assert_handler(  char const *str, char const *file, int line );
#define ASSERT(x) ((void)(!(x) && assert_handler(#x, __FILE__, __LINE__) && debugBreak()))
#else
#define ASSERT(x) 
#endif

