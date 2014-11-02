//
//  TGDataManager.h
//  Taggy
//
//  Created by Nikolay Volosatov on 02.11.14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TGPriceImage.h"

@interface TGDataManager : NSObject

+ (void)fillSample;

+ (NSInteger)recognizedImagesCount;
+ (TGPriceImage *)recognizedImageAtIndex:(NSInteger)index;
+ (void)removeRecognizedImage:(TGPriceImage *)recognizedImage;

+ (void)recognizeImage:(UIImage *)image withCallback:(void (^)(TGPriceImage *priceImage))callback;

@end
