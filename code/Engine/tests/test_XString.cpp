#include"catch.hpp"
#include"XString.h"

TEST_CASE( "Basic","XString")
{
	XString str("Andy");

	REQUIRE(str.Equals("Andy"));
	REQUIRE(!str.Equals("andy"));
	REQUIRE(str.Length()==4);
    
    const char *cstr = str.c_str();
    REQUIRE( strlen(cstr) == str.Length());
}

TEST_CASE("Append")
{
    XString str("ab");
    str.Append("c");
    REQUIRE( str.Equals("abc"));
    
    str = str + "d";
    REQUIRE( str.Equals("abcd"));
    REQUIRE( str.Length() == 4 );
    REQUIRE(strlen(str.c_str())==4 );
}
TEST_CASE("Long + ")
{
    XString s("a");
    long num = 123;
    XString s2 = s + 123;
    REQUIRE( s2.Equals("a123"));
}
TEST_CASE("Large")
{
    XString str;
    for ( int i=0; i < 200; i++ )
        str.Append("a");
    REQUIRE( str.Length() == 200 );
    for (int i=0; i < 500 ; i++ )
        str.Append("b");
    REQUIRE(str.Length() == 700 );
    REQUIRE(str.c_str()[699] == 'b' );
    REQUIRE(str.c_str()[700] == 0 );
    REQUIRE( str.c_str()[200] == 'b' );
    REQUIRE( str.c_str()[199] == 'a' );
    
}