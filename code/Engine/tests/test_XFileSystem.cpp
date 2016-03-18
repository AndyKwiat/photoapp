#include "catch.hpp"
#include "XFileSystem.h"
#include "XStream.h"

TEST_CASE ("Exists and Delete")
{
    char filename[] = "test.txt";
    REQUIRE ( !XFileSystem::UserFileExists(filename));
    XStream str;
    str.Write("test");
    XFileSystem::WriteUserFile(filename,&str );
    REQUIRE( XFileSystem::UserFileExists(filename));
    bool ret = XFileSystem::DeleteUserFile(filename);
    REQUIRE( ret == true );
    REQUIRE( !XFileSystem::UserFileExists(filename));
    
}
TEST_CASE("Invalid filenames")
{
    char fn[] = "nonexistantfile";
    XStream str;
    str.Write("test");
    REQUIRE( !XFileSystem::UserFileExists(fn));
    REQUIRE( !XFileSystem::DeleteUserFile(fn));
    REQUIRE( !XFileSystem::ReadUserFile(fn,&str ));
   

}
TEST_CASE ("Read and Write")
{
    char filename[] = "t2.txt";
    REQUIRE ( !XFileSystem::UserFileExists(filename));
    XStream str;
    str.Write("test2");
    bool ret = XFileSystem::WriteUserFile(filename,&str );
    REQUIRE( ret == true );
    REQUIRE( XFileSystem::UserFileExists(filename));
    XStream readStream;
    bool ret2 = XFileSystem::ReadUserFile(filename,&readStream );
    REQUIRE( ret2 == true );
    XString readString;
    readStream.Read(&readString);
    REQUIRE( readString.Equals("test2"));
    XFileSystem::DeleteUserFile(filename);
    REQUIRE ( !XFileSystem::UserFileExists(filename));
    
}
