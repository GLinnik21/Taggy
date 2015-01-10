//
//  TGRecognizedPrice.h
//  Taggy
//
//  Created by Nikolay Volosatov on 01.11.14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import <Realm/Realm.h>
#import <UIKit/UIKit.h>
#include "TGCurrency.h"

@class TGCurrency;
@class TGPriceImage;

@interface TGRecognizedPrice : RLMObject

@property TGPriceImage *priceImage;

@property CGFloat value;
@property NSData *rectData;
@property TGCurrency *sourceCurrency;
@property TGCurrency *defaultCurrency;
@property CGFloat confidence;

@property CGRect rect;

- (CGFloat)convertedPrice;

- (NSString *)formattedSourcePrice;
- (NSString *)formattedConvertedPrice;

+ (UIImage *)drawPrices:(NSArray *)prices onImage:(UIImage *)image;

@end

// RLMArray<TGRecognizedPrice>
RLM_ARRAY_TYPE(TGRecognizedPrice)
