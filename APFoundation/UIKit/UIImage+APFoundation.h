//
//  UIImage+APBlock.h
//  APBlock
//
//  Created by David Keegan on 3/21/12.
//  Copyright (c) 2012 David Keegan. All rights reserved.
//

#import <UIKit/UIKit.h>

// Helper method for creating unique image identifiers
#define APFoundationImageIdentifier(fmt, ...) [NSString stringWithFormat:(@"%@%@" fmt), \
    NSStringFromClass([self class]), NSStringFromSelector(_cmd), ##__VA_ARGS__]

@interface UIImage (APFoundation)

/** Returns a `UIImage` rendered with the drawing code in the block. 
This method does not cache the image object. */
+ (UIImage *)ap_imageForSize:(CGSize)size withDrawingBlock:(void(^)())drawingBlock;
+ (UIImage *)ap_imageForSize:(CGSize)size opaque:(BOOL)opaque withDrawingBlock:(void(^)())drawingBlock;

/** Returns a cached `UIImage` rendered with the drawing code in the block. 
The `UIImage` is cached in an `NSCache` with the identifier provided. */
+ (UIImage *)ap_imageWithIdentifier:(NSString *)identifier forSize:(CGSize)size andDrawingBlock:(void(^)())drawingBlock;
+ (UIImage *)ap_imageWithIdentifier:(NSString *)identifier opaque:(BOOL)opaque forSize:(CGSize)size andDrawingBlock:(void(^)())drawingBlock;

@end
