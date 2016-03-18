#define CATCH_CONFIG_RUNNER
#include"catch.hpp"
//#include"conio.h"
#include "Tag.h"
#include "TagManager.h"


int main( int argc, char* const argv[] )
{
	// global setup...


	int result = Catch::Session().run( argc, argv );

	// global clean-up...

	//_getch();

	return result;
}


