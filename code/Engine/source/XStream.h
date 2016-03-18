//
//  XStream.h
//  Tagger
//
//  Created by Andy Kwiatkowski on 2016-01-22.
//
//
#include"XList.h"
#include"XString.h"

#ifndef XStream_h
#define XStream_h

class XStream
{
public:
	XStream();
    const char * GetBufferPtr();
    int GetBufferSize();
    void Write( const XString &str );
    void Write( int number );
    void Write( unsigned long number );
    void Write( const void *data, int size );
    
    void Read( XString *str );
    void Read( int *number );
    void Read( unsigned long *number );
    void Read( void *data, int size );
    template<typename T>
    void WritePtrList(const XList<T*> &list)
    {
        Write(list.Count() );
		for ( int i=0; i < list.Count(); i++ )
        {
            list.Get(i)->WriteToStream(this);
        }
    }

	template<typename T>
	void ReadPtrList( XList<T*> *list)
	{
		int count =-1;
		Read(&count);
		ASSERT( count >=0 );
		for ( int i=0; i < count; i++ )
		{
			T *t = new T();		
			t->ReadFromStream(this);
			list->Add(t);
		}
	}

	template<typename T>
	void Write(const XList<T> &list)
	{
		Write(list.Count());
		for ( int i=0; i < list.Count(); i++ )
		{
			Write( list.Get(i) );
		}
	}

	template<typename T>
	void Read(XList<T> *list)
	{
		int count=-1;
		Read(&count);
		ASSERT( count >=0 );
		ASSERT( list->Count()==0 );
		for ( int i=0; i < count; i++ )
		{
			T baseItem;
			Read(&baseItem);
			list->Add(baseItem);
		}
	}
    
private:
	XList<char> m_Buffer;
	int m_ReadPosition;
};


#endif /* XStream_h */
