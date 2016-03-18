/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A collection view cell that displays a thumbnail image.
 */

#import "AAPLGridViewCell.h"

@interface AAPLGridViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *livePhotoBadgeImageView;
@property (weak, nonatomic) IBOutlet UIImageView *checkmarkView;

@end

@implementation AAPLGridViewCell

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
    self.livePhotoBadgeImageView.image = nil;
    self.checkmarkView.hidden = true;
}

-(void)hideCheckmark{
    self.checkmarkView.hidden = true;
}

-(void)showCheckmark{
    self.checkmarkView.hidden = false;
}


- (void)setThumbnailImage:(UIImage *)thumbnailImage {
    _thumbnailImage = thumbnailImage;
    self.imageView.image = thumbnailImage;
}

- (void)setLivePhotoBadgeImage:(UIImage *)livePhotoBadgeImage {
    _livePhotoBadgeImage = livePhotoBadgeImage;
    self.livePhotoBadgeImageView.image = livePhotoBadgeImage;
}

- (IBAction)onClick:(id)sender{
    [self showCheckmark];
}


@end
