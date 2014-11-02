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
@property NSString *rectString;
@property NSString *sourceCurrencyCode;
@property TGCurrency *defaultCurrency;
@property CGFloat confidence;

@end

// RLMArray<TGRecognizedPrice>
RLM_ARRAY_TYPE(TGRecognizedPrice)
