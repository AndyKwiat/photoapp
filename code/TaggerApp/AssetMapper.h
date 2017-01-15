//
//  AssetMapper.h
//  Tagger
//
//  Created by Andy Kwiatkowski on 2016-09-09.
//
//

#ifndef AssetMapper_h
#define AssetMapper_h

class AssetMapper
{
public:
    void Add(PicId pid, const char *str )
    {
        
        if ( ids.Contains(pid))
            return;
        ids.Add(pid);
        localIdentifiers.Add(str);
    }
    void GetLocalIdentifiers( XList<PicId> &picsToGet, XList<const XString*> &listToFill)
    {
        // TODO performance use hashmaps
        const XString *localIdArray = localIdentifiers.GetRawData();
        for ( int i=0; i < picsToGet.Count(); i++ )
        {
            for ( int j=0; j < ids.Count(); j++ )
            {
                if ( picsToGet.Get(i) == ids.Get(j))
                {
                    listToFill.Add( &localIdArray[j] );
                    break;
                }
            }
        }
    }
    void WriteToStream( XStream *str )
    {
        str->Write(ids);
        str->Write(localIdentifiers);
    }
    void ReadFromStream( XStream *str )
    {
        str->Read(&ids);
        str->Read(&localIdentifiers);
    }
    
private:
    XList<PicId> ids;
    XList<XString> localIdentifiers;
};


#endif /* AssetMapper_h */
