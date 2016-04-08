#include "TagManager.h"
#include "Tag.h"
#include "XList.h"
#include "XStream.h"


void TagManager::RemoveTag(  Tag *tag )
{
    m_Tags.Remove( tag );
}
 void TagManager::AddTag( const XString &str )
 {
     m_Tags.Add(new Tag(str));
 }

void TagManager::WriteToStream(XStream *stream)
{
    stream->WritePtrList(m_Tags);
}

void TagManager::ReadFromStream(XStream *stream)
{
    stream->ReadPtrList(&m_Tags);
}

