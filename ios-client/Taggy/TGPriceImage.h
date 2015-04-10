//
//  TGPriceImage.h
//  Taggy
//
//  Created by Nikolay Volosatov on 01.11.14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import <Realm/Realm.h>
#import "TGRecognizedPrice.h"

@class UIImage;

@interface TGPriceImage : RLMObject

@property NSDate *captureDate;
@property NSString *tag;
@property NSData *locationData;

@property RLMArray<TGRecognizedPrice> *prices;

@property (readonly) NSData *sourceImageData;
@property (readonly) NSData *thumbnailImageData;

@property UIImage *image;
@property (readonly) UIImage *thumbnail;

- (NSString *)localizedCaptureDate;

@end

// RLMArray<TGPriceImage>
RLM_ARRAY_TYPE(TGPriceImage)
