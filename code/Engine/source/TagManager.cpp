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
     Tag *tag = new Tag(str);
     tag->ID = m_Tags.Count();
     m_Tags.Add(tag);
 }

void TagManager::WriteToStream(XStream *stream)
{
    stream->WritePtrList(m_Tags);
}

void TagManager::ReadFromStream(XStream *stream)
{
    stream->ReadPtrList(&m_Tags);
    int j = 0;
    foreach(Tag*, t, m_Tags){
        t->ID = j++;
    }
}

