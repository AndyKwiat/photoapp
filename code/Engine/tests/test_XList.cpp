#include "catch.hpp"
#include "XList.h"

TEST_CASE( "Basic XList","XList")
{
	XList<int> list;
	REQUIRE( list.Count() == 0 );

	list.Add(99);
	REQUIRE(list.Count()==1);
	REQUIRE( list.Get(0) == 99);

	list.Add( 2 );
	list.Add(3);
	REQUIRE(list.Count() == 3 );
	REQUIRE(list.Get(1) == 2 );
	REQUIRE(list.Get(2) == 3 );
	list.Remove(2);
	REQUIRE(list.Count() == 2 );
	REQUIRE(list.Get(1) == 3 );
    
    list.Clear();
    REQUIRE( list.Count() == 0 );
    for ( int i=0; i < 20; i++ )
        list.Add(i);
    REQUIRE(list.Count()==20 );
    REQUIRE(list.Contains(19) );
    REQUIRE( !list.Contains(21) );

	list.Clear();
	int arr[] = { 5,6,7,8 };
	list.AddMultiple( arr,4 );
	REQUIRE( list.Count() ==4 );
	REQUIRE( list.Get(0) == 5 );
	REQUIRE( list.Contains(6) );
	REQUIRE( list.Contains(7) );
	REQUIRE (list.Get(3) == 8 );
}