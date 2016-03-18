//
//  AssetLibrary.m
//  photoapp
//
//  Created by Andy Kwiatkowski on 2016-01-08.
//  Copyright © 2016 Andy Kwiatkowski. All rights reserved.
//

//#import <Foundation/Foundation.h>

#include"AssetsLibrary.h"

class AndyAss
{
public:
    void GetLibrary();
};
void AndyAss::GetLibrary()
{
    [[ALAssetsLibrary alloc] init];
}