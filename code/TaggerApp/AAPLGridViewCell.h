/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A collection view cell that displays a thumbnail image.
 */

#include<UIKit/UIKit.h>


@interface AAPLGridViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, strong) UIImage *livePhotoBadgeImage;
@property (nonatomic, copy) NSString *representedAssetIdentifier;
@property (nonatomic) unsigned long assetHash;

-(void)hideCheckmark;
-(void)showCheckmark;

@end
