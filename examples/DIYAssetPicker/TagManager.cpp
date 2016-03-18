//
//  TagManager.cpp
//  DIYAssetPicker
//
//  Created by Andy Kwiatkowski on 2015-03-22.
//

#include "TagManager.h"
#include "string.h"

TagManager gTagManager;



TagManager::TagManager()
{
    m_Tags.Add( new PhotoTag("Vacation"));
    m_Tags.Add( new PhotoTag("Wacking Day"));
}


void TagManager::GetTags( Photo *pic, LinkedList<PhotoTag*> &tagList )
{
    tagList.Clear();
    tagList.Add( m_Tags.GetAtIndex(0));
    tagList.Add( m_Tags.GetAtIndex(1));
}

PhotoTag::PhotoTag( char const *name )
{
    strcpy( m_Name,name );
}
