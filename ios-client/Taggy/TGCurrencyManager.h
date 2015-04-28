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

typedef void (^TGCurrencyUpdateCallback)(TGCurrencyUpdateResult result);
typedef void (^TGCurrencyUpdateProgressCallback)(CGFloat progress);

@interface TGCurrencyManager : NSObject

+ (void)initCurrencies;
+ (void)updateOne:(BOOL)one
          history:(BOOL)history
         callback:(TGCurrencyUpdateCallback)callback
         progress:(TGCurrencyUpdateProgressCallback)progress;

@end
