#include"catch.hpp"
#include"XStream.h"
#include"XString.h"
#include"XList.h"

class testRead
{
public:
	
	void WriteToStream( XStream *str)
	{
		str->Write(testString);
	}
	void ReadFromStream( XStream *str )
	{
		str->Read(&testString);
	}
	XString testString;
};

TEST_CASE( "XStream->XList->Complex types" )
{
	XStream stream;
	testRead obj;
	obj.testString = "AndyDandy";
	testRead obj2;
	obj2.testString ="CandyFandy";
	XList<testRead*> list;
	list.Add( &obj );
	list.Add( &obj2 );
	stream.WritePtrList(list);

	XList<testRead*> readList;
	stream.ReadPtrList(&readList);
	REQUIRE( readList.Count() == list.Count() );
	for ( int i=0; i < readList.Count(); i++)
	{
		REQUIRE( readList.Get(i)->testString.Equals( list.Get(i)->testString) );
	}
}
TEST_CASE( "XStream_XList-base types")
{
	XStream stream;
	XList<int> list;
	list.Add(1);
	list.Add(2);
	list.Add(3);
	stream.Write(list);
	XList<int> newList;
	stream.Read(&newList);
	REQUIRE( newList.Count() == list.Count() );
	for ( int i=0; i < newList.Count(); i++ )
	{
		REQUIRE( newList.Get(i) == list.Get(i) );
	}
}
TEST_CASE( "XStream_Basic")
{
	XStream stream;
	XString string ="Andy";
	XString readString;
	int readNumber=0;
	int number= 1234;
	stream.Write( string );
	stream.Write(number);
	stream.Read( &readString );
	REQUIRE( readString.Equals( string) );
	stream.Read( &readNumber );
	REQUIRE( readNumber == number );

}


