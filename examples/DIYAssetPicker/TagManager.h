//
//  TagManager.h
//  DIYAssetPicker
//
//  Created by Andy Kwiatkowski on 2015-03-22.
//

#ifndef DIYAssetPicker_TagManager_h
#define DIYAssetPicker_TagManager_h
#include "LinkedList.h"

class Photo
{
public:
    void *m_Asset;
};

class PhotoTag
{
public:
    static const int MAX_TAG_SIZE =35;
    PhotoTag( char const *name );
    char *GetName(){ return m_Name; };
private:
    char m_Name[MAX_TAG_SIZE];
};

class TagManager
{
public:
    TagManager();
    void GetTags( Photo* photo ,LinkedList<PhotoTag*> &tagList );
    void GetAllTags( LinkedList<PhotoTag*> &tagList);
private:
    LinkedList<PhotoTag*> m_Tags;
};

extern TagManager gTagManager;
#endif
