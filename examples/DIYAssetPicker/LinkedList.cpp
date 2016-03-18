#include"LinkedList.h"

static const int MAX_LINK_NODES = 10000;
static LinkedListNode m_Cache[MAX_LINK_NODES];

LinkedListNode *m_NextFree = NULL;
void LinkedListNode::Init()
{
	static bool Init = false;
	ASSERT( !Init );
	Init =true;
	ASSERT( !m_NextFree );
	for ( int i=0; i < MAX_LINK_NODES-1; i++ )
	{
		m_Cache[i].Data = &m_Cache[i+1];
	}
	m_Cache[MAX_LINK_NODES-1].Data = NULL;
	m_NextFree = &m_Cache[0];
	
}

LinkedListNode* LinkedListNode::GetNew()
{
	if ( !m_NextFree )
		Init();
	LinkedListNode *next = m_NextFree;
	ASSERT( next && "RAN OUT OF MAX_LINK NODES");
	m_NextFree = (LinkedListNode*)next->Data;
	return next;
}

void LinkedListNode::Free(LinkedListNode *ptr)
{
	ptr->Data = m_NextFree;
	m_NextFree = ptr;

}
