#pragma once
#include"debugfuncs.h"
#include"memory.h"

#define foreach( t, v, list ) for ( int i=0; i < (list).Count(); i++ )for ( t v = (list).Get(i);v!=NULL;v=NULL)
template <class T>
class XList {
public:
    XList();
    ~XList();
    void Add(  const T newMember );
	void AddMultiple( const T *data, int itemCount );
    int Count()const { return m_Count; } ;
    T Get(int index)const { ASSERT( index >=0 && index < m_Count); return m_Data[index]; }
    void Remove(   T oldMember );
    void Clear();
    bool  Contains( T member )const;
	const T* GetRawData(){ return m_Data; }
private:
	XList(const XList& that);	// don't let anyone copy lists, this leads to trouble
	void AddCapacity( int extraCapacity );
    int m_Capacity;
    int m_Count;
    T *m_Data;
};
template<class T>
XList<T>::XList():
m_Count(0),
m_Capacity(50)
{
    m_Data = new T[m_Capacity];
}
template<class T>
void XList<T>::Add(const T newMember)
{
    m_Data[m_Count] = newMember;
    m_Count++;
    ASSERT( m_Count <= m_Capacity );
    if ( m_Count == m_Capacity )
    {
        AddCapacity(m_Capacity );	// double it
    }
}

template<class T>
void XList<T>::AddCapacity( int extraCapacity )
{
	ASSERT( extraCapacity > 0 );
	T *oldData = m_Data;
	m_Capacity = m_Capacity + extraCapacity;
	m_Data = new T[m_Capacity];
	for ( int i=0; i < m_Count ; i++ )
		m_Data[i] = oldData[i];
	delete[] oldData;
}

template<class T>
void XList<T>::AddMultiple(  const T *data, int itemCount )
{
	ASSERT(itemCount>=0);
	if ( m_Count +itemCount >= m_Capacity )
	{
		AddCapacity( itemCount );
	}
	memcpy(&m_Data[m_Count],data,sizeof(T) * itemCount );
	m_Count += itemCount;
}

template<class T>
XList<T>::~XList()
{
    delete []m_Data;
}
template<class T>
void XList<T>::Clear()
{
    m_Count =0;
}

template<class T>
bool XList<T>::Contains(T item) const 
{
    for( int i=0; i < m_Count; i++ )
        if ( m_Data[i] == item)
            return true;
    return false;
}
template<class T>
void XList<T>::Remove( T oldMember)
{
    int i;
    for (  i=0; i < m_Count ; i++ )
    {
        if ( m_Data[i] == oldMember )
            break;
    }
    if ( i >= m_Count ) 
        return;
    m_Count--;
    for ( int j=i; j < m_Count; j++ )
    {
        m_Data[j] = m_Data[j+1];
    }
    
}




