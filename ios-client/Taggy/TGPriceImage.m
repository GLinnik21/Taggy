//
//  TGPriceImage.m
//  Taggy
//
//  Created by Nikolay Volosatov on 01.11.14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import "TGPriceImage.h"
#import "TGCommon.h"

static CGSize const kTGThumbnailSize = { 100.0f, 100.0f };

@interface TGPriceImage()

@property NSData *sourceImageData;
@property NSData *thumbnailImageData;

@end

@implementation TGPriceImage

- (NSString *)localizedCaptureDate
{
    return [NSDateFormatter localizedStringFromDate:self.captureDate
                                          dateStyle:NSDateFormatterMediumStyle
                                          timeStyle:NSDateFormatterShortStyle];
}

- (UIImage *)image
{
    return [UIImage imageWithData:self.sourceImageData];
}

- (void)setImage:(UIImage *)image
{
    self.sourceImageData = UIImageJPEGRepresentation(image, 1.0f);
    UIImage *thumbnail = [TGCommon imageWithImage:image scaledToSizeWithSameAspectRatio:kTGThumbnailSize];
    self.thumbnailImageData = UIImageJPEGRepresentation(thumbnail, 1.0f);
}

- (UIImage *)thumbnail
{
    return [UIImage imageWithData:self.thumbnailImageData];
}

+ (NSArray *)ignoredProperties
{
    return @[@"image"];
}

@end
