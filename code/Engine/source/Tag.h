#pragma once
#include "XString.h"
#include"XList.h"
#include"CustomTypes.h"

class XStream;
class Tag {
public:
    Tag(const XString &str);
	Tag(){};// used for serialization
    const XString& GetName()const { return m_Name; }
    void TagPic( PicId hash );
    void UnTagPic( PicId hash );
    const XList<PicId> &GetTaggedPics()const{ return m_TaggedPics; };
    void WriteToStream( XStream *str);
	void ReadFromStream( XStream *str );
    void Rename( const XString &str );
    int ID;  // convenience
private:
    XList<PicId> m_TaggedPics;
    XString m_Name;
};



