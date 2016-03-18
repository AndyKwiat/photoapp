#pragma once
#include"XString.h"
#include"XList.h"

class Tag;
class XStream;
class TagManager
{
public:
    void AddTag( const XString &str );
    void RemoveTag(  Tag *tag );
    const XList<Tag*>*  GetAllTags()const{ return &m_Tags; }
    void WriteToStream( XStream *stream );
    void ReadFromStream( XStream *stream );
private:
    XList<Tag*> m_Tags;
};