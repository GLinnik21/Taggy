//
//  TGCommon.m
//  Taggy
//
//  Created by Nikolay Volosatov on 02.11.14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import "TGCommon.h"
#import <UIKit/UIKit.h>

@implementation TGCommon

+ (UIImage *)imageWithImage:(UIImage *)sourceImage scaledToSizeWithSameAspectRatio:(CGSize)targetSize
{
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;

    CGFloat scaleFactor = 1.0f;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;

    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;

        if (widthFactor < heightFactor) {
            scaleFactor = widthFactor;
        }
        else {
            scaleFactor = heightFactor;
        }

        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
    }

    UIGraphicsBeginImageContext(CGSizeMake(scaledWidth, scaledHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, scaledWidth, scaledHeight)];
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return smallImage;
}

@end
