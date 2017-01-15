//
//  Connector.cpp
//  Tagger
//
//  Created by Andy Kwiatkowski on 2016-01-22.
//
//

#import <Foundation/Foundation.h>
#include"XList.h"
#include"TagManager.h"
#include"XStream.h"
#include"XFileSystem.h"

//@AUTOGENERATE
#include"Connector.hpp" //@INCLUDE "Tag.h"

#include"AssetMapper.h"

AssetMapper assetMapper;
XList<unsigned long> selectedPics;
XList<Tag*> selectedTags;
TagManager tagManager;
XList<PicId> filteredPics;

const char *tagsDBFilename ="tagsDB";

void CalculateFilteredPics()
{
    filteredPics.Clear();
    for ( int i=0; i < selectedTags.Count(); i++ )
    {
        const XList<PicId> &pics = selectedTags.Get(i)->GetTaggedPics();
        for( int j=0; j < pics.Count(); j++ )
        {
            PicId p = pics.Get(j);
            if ( !filteredPics.Contains(p))
                filteredPics.Add(p);
        }
    }

}
void LoadTagManager()
{
    if ( !XFileSystem::UserFileExists(tagsDBFilename))
        return;
    XStream str;
    XFileSystem::ReadUserFile(tagsDBFilename,&str );
    tagManager.ReadFromStream(&str);
    assetMapper.ReadFromStream(&str);
}

void SaveTagManager()
{
    XStream str;
    tagManager.WriteToStream(&str);
    assetMapper.WriteToStream(&str);
    XFileSystem::WriteUserFile(tagsDBFilename,&str );
}

void Init()
{
  //  XFileSystem::DeleteUserFile(tagsDBFilename);
    LoadTagManager();
  //  tagManager.AddTag("babies");
}

bool ToggleTagSelection ( Tag *tag ){
    if ( selectedTags.Contains(tag))
    {
        selectedTags.Remove(tag);
        return false;
    }
    selectedTags.Add(tag);
    return true;

}

namespace SinglePicViewMediator{
    void TagPic( PicId pic,Tag * tag ){
        tag->TagPic(pic);
        SaveTagManager();
    }
    
    void UnTagPic( PicId pic,Tag * tag ){
        tag->UnTagPic(pic);
        SaveTagManager();
    }
    
    void GetTagsWithPic( PicId pic, XList<Tag*> *listTags, const char *localID){
        if ( localID != NULL ){
            assetMapper.Add(pic, localID);
        }
        // PERFORMANCE TODO
        foreach ( Tag* , t, *tagManager.GetAllTags()){
            const XList<PicId> &list = t->GetTaggedPics();
            for ( int i=0; i < list.Count(); i++ ){
                if ( list.Get(i) == pic )
                    listTags->Add(t);
            }
        }
    }
    bool PicHasTag( PicId pic, const Tag* tag ){
        const XList<PicId> &list = tag->GetTaggedPics();
        for ( int i=0; i < list.Count(); i++)
        {
            if ( list.Get(i)==pic )
                return true;
        }
        return false;
    }
    void GetAllTags( XList<Tag*> *list ){
        list->AddRange( tagManager.GetAllTags());
    }
}
namespace FilterMenuMediator
{

    bool IsTagSelected(  Tag *tag )
    {
        return selectedTags.Contains(tag);
    }
    int GetNumSelectedPhotos()
    {
        CalculateFilteredPics();
        return filteredPics.Count();
    }
    // returns whethere the tag is selected or not now
    bool OnTagClicked( Tag *tag)
    {
        return ToggleTagSelection(tag);
    }
    int GetNumberOfTags()
    {
        return tagManager.GetAllTags()->Count();
    }
    Tag *GetTagAtIndex( int index )
    {
        return tagManager.GetAllTags()->Get(index);
    }
}

namespace TagsMenuMediator
{
    void OnClose()
    {
        SaveTagManager();
    }
    
    Tag* GetTagAtIndex(int index )
    {
        return tagManager.GetAllTags()->Get(index);
    }
    
    int GetSelectedPhotoCountWithTag( Tag * tag )
    {
        int count=0;
        const XList<unsigned long> &taggedPics = tag->GetTaggedPics();
        for ( int i=0; i < selectedPics.Count(); i++ )
        {
            if ( taggedPics.Contains(selectedPics.Get(i)) )
                count++;
        }
        return count;
    }
    
    void TagAllSelectedPics( Tag *tag )
    {
        for ( int i=0; i < selectedPics.Count(); i++ )
        {
            tag->TagPic( selectedPics.Get(i));
        }
    }
    
    void UnTagAllSelectedPics( Tag *tag )
    {
        for ( int i=0; i < selectedPics.Count(); i++ )
        {
            tag->UnTagPic( selectedPics.Get(i));
        }
    }
    
    
    int GetNumberOfTags()
    {
        return tagManager.GetAllTags()->Count();
    }
    
    int GetNumberOfSelectedPhotos()
    {
        return selectedPics.Count();
    }
    
    bool AttemptAddTag( const char * tag )
    {
        tagManager.AddTag( tag );
        return true;    // TODO: need failure state 
    }
    void DeleteTag( Tag *tag)
    {
        tagManager.RemoveTag(tag);
    }
}
namespace GridViewController{
    
    bool IsTagSelected( Tag *tag ){
        return selectedTags.Contains(tag);
    }
    void OnTagClicked(  Tag * tag , bool IsSelectionMode, bool SelectionModeTagPic)
    {
        if ( IsSelectionMode ){
            if ( !SelectionModeTagPic ){
                for ( int i=0; i < selectedPics.Count(); i++ ){
                    tag->UnTagPic(selectedPics.Get(i));
                }
            }
            else{
                for ( int i=0; i < selectedPics.Count(); i++ ){
                    tag->TagPic(selectedPics.Get(i));
                }
            }
            SaveTagManager();
        }
        else{
            ToggleTagSelection(tag);
            CalculateFilteredPics();
        }
    }
    bool IsAssetSelected(PicId hash)
    {
        return selectedPics.Contains(hash);
    }
    void SelectAsset(PicId hash, const char *localIdentifier )
    {
        selectedPics.Add(hash);
        assetMapper.Add(hash, localIdentifier );
    }
    void DeSelectAsset(PicId hash )
    {
        ASSERT( selectedPics.Contains(hash));
        selectedPics.Remove(hash);
    }
    void OnExitSelectionMode(){
        selectedPics.Clear();
    }
    bool GetLocalIdentifiersToLoad( XList<const XString*> &listToFill )
    {
        ASSERT( listToFill.Count() == 0 );
        if ( selectedTags.Count() <=0 )
            return false;
        assetMapper.GetLocalIdentifiers( filteredPics, listToFill );
        return true;
        
    }
    void OnTextFilterChange( const char *textFilterContents, XList< Tag*> &tagsToShow)
    {
        const XList<Tag*> *list = tagManager.GetAllTags();
        tagsToShow.Clear();
        foreach( Tag*, t, (*list)){
            tagsToShow.Add(t);
        }
    }
    void RenameTag( Tag *tag, const char *newName ){
        tag->Rename(newName);
        SaveTagManager();
    }
    void DeleteTag( Tag *tag ){
        tagManager.RemoveTag(tag);
        SaveTagManager();
    }
}


const char *GetDocumentsDirectory()
{
  
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = paths.firstObject;
    return [[basePath stringByAppendingString:@"/"] UTF8String];
}


class Connector
{
public:
    Connector()
    {
        Init();
    }
};
Connector connector;    // just to run that constructor
