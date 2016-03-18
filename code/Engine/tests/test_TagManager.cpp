#include "catch.hpp"
#include"Tag.h"
#include"TagManager.h"

TEST_CASE( "TagManager add/remove","TagManager")
{
	TagManager tm;
	const XList<Tag*> *list;
	tm.AddTag(XString("AndyDandy"));
	list = tm.GetAllTags();
	REQUIRE( list->Count() == 1);
	REQUIRE( list->Get(0)->GetName().Equals("AndyDandy") );
	tm.AddTag("test");
	REQUIRE( list->Count() == 2 );
	tm.RemoveTag(list->Get(0));
	REQUIRE(list->Count()==1 );
	Tag tag("test");
	tm.RemoveTag(&tag);
	REQUIRE(list->Count()==1 );


}
