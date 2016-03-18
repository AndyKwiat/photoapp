/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A view controller displaying a grid of assets.
 */

#include<UIKit/UIKit.h>
#include<Photos/Photos.h>

@interface AAPLAssetGridViewController : UICollectionViewController

@property (nonatomic, strong) PHFetchResult *assetsFetchResults;
@property (nonatomic, strong) PHAssetCollection *assetCollection;

@end
