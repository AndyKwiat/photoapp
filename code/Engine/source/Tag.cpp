
#include "Tag.h"
#include "XStream.h"

Tag::Tag(const XString &str): 
m_Name(str)
{
}

void Tag::TagPic( PicId hash )
{
    if ( !m_TaggedPics.Contains(hash))
        m_TaggedPics.Add(hash);
}

void Tag::UnTagPic( PicId hash )
{
    m_TaggedPics.Remove(hash);
}

void Tag::WriteToStream(XStream *stream)
{
    stream->Write(m_Name);
    stream->Write(m_TaggedPics);
}

void Tag::ReadFromStream(XStream *stream)
{
	stream->Read(&m_Name);
	stream->Read(&m_TaggedPics);
}


