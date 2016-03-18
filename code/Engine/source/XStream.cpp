#include"XStream.h"

XStream::XStream()
{
	m_ReadPosition = 0;
}

const char * XStream::GetBufferPtr()
{
    return m_Buffer.GetRawData();
}

int XStream::GetBufferSize()
{
    return m_Buffer.Count();
}
void XStream::Write( const XString &str )
{
	Write( str.Length()+1 );
    const char *cstr = str.c_str();
    for ( int i=0; i < str.Length(); i++ )
    {
        ASSERT( cstr[i] != 0 );
    }
    ASSERT( cstr[str.Length()]== 0 );
	Write( str.c_str(), str.Length()+1);
}
void XStream::Read( XString *str )
{
	int length=0;
	Read( &length);
	ASSERT( str->Length() == 0 );
	char *buffer = new char[length];
	Read( buffer, length );
    for ( int i=0; i < length-1; i++ )
    {
        ASSERT( buffer[i] != 0 );
    }
    ASSERT( buffer[length-1]==0 );
    
	str->Append(buffer);
	delete buffer;
}

void XStream::Write( int number )
{
	Write( &number, sizeof(int) );
}
void XStream::Read( int *number )
{
	Read( number, sizeof(int) );
}

void XStream::Write( unsigned long number )
{
	Write( &number, sizeof(unsigned long) );
}
void XStream::Read( unsigned long *number )
{
	Read( number, sizeof(unsigned long) );
}


void XStream::Write( const void *data, int size )
{
    ASSERT( m_ReadPosition == 0 ); // catch cases where you accidently write and you meant to read
    m_Buffer.AddMultiple((const char*)data,size);
}
void XStream::Read(  void *data, int size )
{
	memcpy(data,m_Buffer.GetRawData()+ m_ReadPosition,size );
	m_ReadPosition+= size;
	ASSERT( m_ReadPosition <= m_Buffer.Count() );
}