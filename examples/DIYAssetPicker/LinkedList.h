#ifndef __LINKED_LIST_H
#define __LINKED_LIST_H
#include "DebugFuncs.h"

struct LinkedListNode
{
	LinkedListNode *Prev;
	LinkedListNode *Next;
	void *Data;
	static LinkedListNode* GetNew();
	static void Free(LinkedListNode *ptr);
	static void Init();

};

template <class dataType> class LinkedList
{
private:
	

public:
	LinkedList(){ 
		Start = NULL; End = NULL; m_Iterator = NULL;Count = 0;

		 }

	~LinkedList()
	{
		Clear();
	}
	
	LinkedListNode *Start;
	LinkedListNode *End;
	
	dataType Current;
	int Count;
	dataType GetLast()
	{
		ASSERT( Count > 0 );
		ASSERT( End );
		return (dataType)End->Data;
	}
	dataType GetFirst()
	{
		if ( Count <=0 )
			return NULL;
		ASSERT( Count > 0 );
		ASSERT( Start );
		return (dataType)Start->Data;
	}
	void Begin()
	{
		m_Iterator = Start;
	}
	bool Next()
	{
		if ( !m_Iterator )
		{
			Current = NULL;
			return false;
		}
		Current = (dataType)m_Iterator->Data;
		m_Iterator = m_Iterator->Next;
		return true;
	}
	void RemoveCurrent()
	{
		if ( !m_Iterator )
		{
			RemoveLast();
			return;
		}
		
		ASSERT( m_Iterator->Prev );
		LinkedListNode *n = m_Iterator->Prev;
		
		if ( n== Start ) 
			Start = n->Next;
		if ( n == End )
			End = n->Prev;
		if ( n->Prev )
			n->Prev->Next = n->Next;
		if ( n->Next )
			n->Next->Prev = n->Prev;
		LinkedListNode::Free(n);
		Count--;

	}
	int IndexOf( dataType d )
	{
		int index = 0;
		LinkedListNode *n = Start;
		while ( n )
		{
			if ( n->Data == d )
				return index;
			n = n->Next;
			index++;
		}
		return -1;
	}
	bool Contains( dataType d )
	{
		LinkedListNode *n = Start;
		while ( n )
		{
			if ( n->Data == d )
				return true;
			n= n->Next;
		}
		return false;
	}

	dataType GetAtIndex( int i)const
	{
		int index = 0;
		LinkedListNode *n = Start;
		while ( n )
		{
			if ( i == index )
				return (dataType)n->Data;
			n = n->Next;
			index++;
		}
		ASSERT(0);
		return (dataType)Start->Data;
	}
	void Add( dataType item )
	{
		ASSERT( Count >=0 );
		LinkedListNode *n = LinkedListNode::GetNew();
		n->Data = (void*)item;
		if ( Start == NULL )
		{
			Start = n;
			End = n;
			n->Prev = NULL;
			n->Next = NULL;
		}
		else
		{
			End->Next = n;
			n->Prev= End;
			End = n;
			n->Next = NULL;
		}
		Count++;
	}

	void InsertAt( dataType item, int index )
	{
		
		ASSERT( index >=0 && index <= Count );
		LinkedListNode *spot = Start;
		while ( index > 0 )
		{
			if ( !spot )
				break;
			spot = spot->Next;
			index--;
		}
		if ( !spot )
		{
			Add(item);	// regular add
			return;
		}
		LinkedListNode *n = LinkedListNode::GetNew();
		n->Data = (void*)item;
		if ( spot == Start )
		{
			Start = n;
		}
		n->Prev = NULL;
		n->Next = NULL;
		if ( spot->Prev )
		{
			spot->Prev->Next = n;
			n->Prev = spot->Prev;
		}
		spot->Prev = n;
		n->Next = spot;
		Count++;
	}
	void Clear()
	{
		while ( Count > 0 )
			RemoveLast();


	}
	void RemoveFirst()
	{
		LinkedListNode *n = Start;
		if ( Start )
		{
			Start = Start->Next;
			if ( Start )
				Start->Prev = NULL;
			LinkedListNode::Free( n );
		}
		if ( Start == NULL )
			End = NULL;
		Count--;
	}
	void RemoveLast()
	{
		LinkedListNode *n = End;
		if ( End )
		{
			End= End->Prev;
			if ( End )
				End->Next = NULL;
			LinkedListNode::Free(n);
		}
		if ( End == NULL )
			Start = NULL;
		Count--;
	}
	void Remove (dataType d )
	{
		for ( LinkedListNode *n = Start; n!= NULL; n = n->Next )
		{
			if ( n->Data == d )
			{
				if ( n== Start ) 
					Start = n->Next;
				if ( n == End )
					End = n->Prev;
				if ( n->Prev )
					n->Prev->Next = n->Next;
				if ( n->Next )
					n->Next->Prev = n->Prev;
				
				LinkedListNode::Free(n);
				Count--;
				break;
			}
		}
	}
	
private:
	LinkedListNode *m_Iterator;
	

};





#endif