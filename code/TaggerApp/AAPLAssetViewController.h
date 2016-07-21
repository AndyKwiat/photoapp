/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A view controller displaying an asset full screen.
 */

#include<UIKit/UIKit.h>
#include<Photos/Photos.h>


@interface AAPLAssetViewController : UIViewController

@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, strong) PHAssetCollection *assetCollection;
@property (nonatomic, strong) PHFetchResult *assetsFetchResults;
@property (nonatomic) NSInteger assetFetchIndex;

@end
