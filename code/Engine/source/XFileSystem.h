#pragma once

class XStream;
namespace XFileSystem
{
    bool WriteUserFile( const char * filename, XStream *stream );
    bool ReadUserFile( const char *filename, XStream *stream );
    bool UserFileExists( const char *filename );
    bool DeleteUserFile( const char *filename );
}