#pragma once

class XString {
public:
    XString(const XString &string);
    XString(const char *string);
	XString();
    ~XString();
    bool Equals( const XString &str )const;
    int Length()const{ return m_Length; };
    const char *c_str()const{ return m_Data; }
    void Append( const char *endString );
    void Append( const XString &endString );
    XString & operator=(const XString &other );
    XString &operator+( long num);
    XString &operator+( int num);
    XString &operator+(const XString &);

private:

    void Init();
    int m_Length;
    static const int MAX_DATA = 255;
    char *m_Data;
    char m_BaseData[MAX_DATA];
    bool m_IsLarge;
    
};

// convenience functions for easier string formatting
//XString operator+( XString str, long number);
XString operator+(  const char *a ,const XString &b );



