//
//  TGCurrencyManager.h
//  Taggy
//
//  Created by Nikolay Volosatov on 10.11.14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TGCurrencyUpdateResult) {
    TGCurrencyUpdateResultSuccess,
    TGCurrencyUpdateResultNoInternet,
    TGCurrencyUpdateResultServerError,
};

typedef void(^TGCurrencyUpdateCallback)(TGCurrencyUpdateResult result);

@interface TGCurrencyManager : NSObject

+ (void)initCurrencies;
+ (void)updateWithCallback:(TGCurrencyUpdateCallback)callback;

@end
