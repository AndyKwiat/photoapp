/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A category on CIImage for convienience methods.
 */

#include<CoreImage/CoreImage.h>

@interface CIImage (Convenience)

- (NSData *)aapl_jpegRepresentationWithCompressionQuality:(CGFloat)compressionQuality;

@end
