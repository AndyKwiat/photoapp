#include<string.h>
#include<stdio.h>
#include"debugFuncs.h"
#include "XString.h"

XString::XString(const XString &str)
{
    Init();
    Append(str.c_str());
}
XString::XString(const char *string) {
    Init();
    Append( string );
}
XString::XString()
{
    Init();
}

XString & XString::operator=(const XString &other )
{
    if ( m_IsLarge )
        delete m_Data;
    Init();
    Append(other);
    return *this;
}
void XString::Init()
{
    m_Length = 0;
    m_Data = m_BaseData;
    m_IsLarge= false;
}

void XString::Append(const XString &string )
{
    Append( string.c_str());
}
void XString::Append( const char *string )
{
    int appendLength = (int)strlen(string);
    
    if ( m_IsLarge || m_Length + appendLength >= MAX_DATA )
    {
        char *newPtr = new char[m_Length + appendLength+1];
        memcpy( newPtr, m_Data, m_Length  );
        memcpy( newPtr + m_Length, string, appendLength+1 );
        if ( m_IsLarge )
            delete m_Data;
        m_Data = newPtr;
        m_Length = m_Length + appendLength;
        m_IsLarge = true;
    }
    else
    {
        strcpy( m_Data + m_Length, string );
        m_Length = m_Length + appendLength;
    }

}
XString::~XString()
{
    if ( m_IsLarge )
        delete m_Data;
}

XString & XString::operator+(long number )
{
    char str[100];
    sprintf(str,"%ld",number);
    Append(str);
    return *this;
}

XString & XString::operator+(int number )
{
    char str[100];
    sprintf(str,"%d",number);
    Append(str);
    return *this;
}


XString & XString::operator+(const XString &str )
{
    Append( str);
    return *this;
}

XString operator+(  const char *a ,const XString &b )
{
    XString str (a);
    str.Append(b);
    return str;
}

bool XString::Equals(const XString& str) const
{
    int index = 0;
    if ( m_Length != str.m_Length )
        return false;
    while ( str.m_Data[index] == m_Data[index])
    {
        if ( m_Data[index] == 0 )
            return true;
        index++;
    }
    return false;
}
