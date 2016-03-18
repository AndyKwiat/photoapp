#include<stdio.h>
#include "XFileSystem.h"
#include "XString.h"
#include "Logger.h"
#include "XStream.h"

const char *GetDocumentsDirectory();

namespace XFileSystem
{
    bool WriteUserFile( const char * filename, XStream *stream )
    {
        XString path ( GetDocumentsDirectory() );
        path.Append(filename);
        FILE *fp = fopen(path.c_str(),"wb");
        if ( !fp )
        {
            Logger::Error("Unable to open file for writing: " + path );
            return false;
        }
        size_t written = fwrite(stream->GetBufferPtr(), stream->GetBufferSize(), 1,fp );
        if ( written < 1 )
        {
            Logger::Error("Error writing to file: " + path );
            fclose(fp);
            return false;
        }
        fclose(fp);
        return true;
    }
    bool ReadUserFile( const char *filename, XStream *stream )
    {
        XString path ( GetDocumentsDirectory() );
        path.Append(filename);
        FILE *fp = fopen(path.c_str(),"rb");
        if ( !fp )
        {
            Logger::Error("Unable to open file for read: " + path );
            return false;
        }
        fseek(fp, 0, SEEK_END);
        long fsize = ftell(fp);
        if ( fsize == 0 )
        {
            fclose(fp);
            return true;
        }
        fseek(fp, 0, SEEK_SET);
        char *string = new char[fsize+1];
        if ( string == NULL )
        {
            Logger::Error( XString( "Can't allocate memory for filesize of: ") +(fsize+1) + " file: " + path);
            return false;
        }
        size_t read = fread( string, fsize,1,fp );
        if ( read < 1 )
        {
            Logger::Error("Error reading file: " + path );
            fclose(fp);
            return false;
        }
        stream->Write(string,(int)fsize);
        fclose(fp);
        return true;

    }
    bool DeleteUserFile( const char *filename )
    {
        XString path ( GetDocumentsDirectory() );
        path.Append(filename);
        if ( remove( path.c_str()) != 0 )
            return false;
        return true;
    }
    bool UserFileExists( const char *filename )
    {
        XString path ( GetDocumentsDirectory() );
        path.Append(filename);
        FILE *fp = fopen(path.c_str(),"rb");
        if ( fp == NULL )
            return false;
        return true;
    }
    
}

