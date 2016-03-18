#include "catch.hpp"
#include "Tag.h"
#include "XStream.h"

TEST_CASE ("Tag_Serialization")
{
	Tag tag("candy");
	tag.TagPic(1);
	tag.TagPic(2);
	XStream stream;
	tag.WriteToStream(&stream);
	Tag t2;
	t2.ReadFromStream(&stream);
	REQUIRE( t2.GetName().Equals( tag.GetName() ) );
	const XList<PicId> &pics = t2.GetTaggedPics();
	const XList<PicId> &pics1 = tag.GetTaggedPics();
	REQUIRE( pics.Count() == 2 );
	REQUIRE( pics.Count() == pics1.Count() );
	for ( int i=0; i < pics.Count() ; i++ )
	{
		REQUIRE( pics.Get(i) == pics1.Get(i) );
	}
}
TEST_CASE( "Tag_Basic")
{
	Tag tag("candy");
	REQUIRE(tag.GetName().Equals("candy"));
	tag.TagPic(1);
	tag.TagPic(2);
	const XList<PicId> &list = tag.GetTaggedPics();
	REQUIRE( list.Contains(1) );
	REQUIRE( list.Contains(2) );
	REQUIRE( list.Count()==2 );
	tag.UnTagPic(1);
	const XList<PicId> &list2 = tag.GetTaggedPics();
	REQUIRE( !list2.Contains(1) );
	REQUIRE( list2.Contains(2)) ;
	tag.UnTagPic(2);
	const XList<PicId> &list3 = tag.GetTaggedPics();
	REQUIRE( list3.Count() == 0 );

}

