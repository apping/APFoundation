//
//  UIImage+APBlock.m
//  APBlock
//
//  Created by David Keegan on 3/21/12.
//  Copyright (c) 2012 David Keegan. All rights reserved.
//

#import "UIImage+APFoundation.h"

@implementation UIImage (APFoundation)

#pragma mark -
#pragma mark Block drawing and cache

+ (NSCache *)ap_drawingCache{
    static NSCache *cache = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        cache = [[NSCache alloc] init];
    });
    return cache;
}

+ (UIImage *)ap_imageForSize:(CGSize)size opaque:(BOOL)opaque withDrawingBlock:(void(^)())drawingBlock{
    if(size.width <= 0.0f || size.height <= 0.0f){
        return nil;
    }
    
    UIGraphicsBeginImageContextWithOptions(size, opaque, 0.0f);
    if(drawingBlock){
        drawingBlock();
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)ap_imageForSize:(CGSize)size withDrawingBlock:(void(^)())drawingBlock{
    return [self ap_imageForSize:size opaque:NO withDrawingBlock:drawingBlock];
}

+ (UIImage *)ap_imageWithIdentifier:(NSString *)identifier opaque:(BOOL)opaque forSize:(CGSize)size andDrawingBlock:(void(^)())drawingBlock{
    UIImage *image = [[self ap_drawingCache] objectForKey:identifier];
    if(image == nil && (image = [self ap_imageForSize:size opaque:opaque withDrawingBlock:drawingBlock])){
        [[self ap_drawingCache] setObject:image forKey:identifier];
    }
    return image;
}

+ (UIImage *)ap_imageWithIdentifier:(NSString *)identifier forSize:(CGSize)size andDrawingBlock:(void(^)())drawingBlock{
    return [self ap_imageWithIdentifier:identifier opaque:NO forSize:size andDrawingBlock:drawingBlock];
}

static CGFloat edgeSizeFromCornerRadius(CGFloat cornerRadius) {
    return cornerRadius * 2 + 1;
}

+ (UIImage *)ap_imageWithColor:(UIColor *)color
                  cornerRadius:(CGFloat)cornerRadius {
    CGFloat minEdgeSize = edgeSizeFromCornerRadius(cornerRadius);
    CGRect rect = CGRectMake(0, 0, minEdgeSize, minEdgeSize);
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
    roundedRect.lineWidth = 0;
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0f);
    [color setFill];
    [roundedRect fill];
    [roundedRect stroke];
    [roundedRect addClip];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(cornerRadius, cornerRadius, cornerRadius, cornerRadius)];
}

+ (UIImage *)ap_imageWithColor:(UIColor *)color andSize:(CGSize)size {
    return [UIImage ap_imageForSize:size opaque:YES withDrawingBlock:^{
        UIBezierPath* rPath = [UIBezierPath bezierPathWithRect:CGRectMake(0., 0., size.width, size.height)];
        [color setFill];
        [rPath fill];
    }];
}

@end
