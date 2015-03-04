//
//  TGCurrencyManager.m
//  Taggy
//
//  Created by Nikolay Volosatov on 10.11.14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import "TGCurrencyManager.h"
#import <Realm/Realm.h>
#import <Reachability/Reachability.h>
#import "TGCurrency.h"

static NSString *const kTGCurrencyLink = @"http://api.taggy.by/rates";

@implementation TGCurrencyManager

+ (void)updateWithCallback:(TGCurrencyUpdateCallback)callback
{
    NSError *error = nil;
    NSURL *URL = [NSURL URLWithString:kTGCurrencyLink];
    Reachability *apiReachable = [Reachability reachabilityWithHostname:URL.host];

    if ([apiReachable isReachable]) {
        [self updateFromURL:URL error:&error];

        if (error != nil) {
            if (callback != nil) {
                callback(TGCurrencyUpdateResultServerError);
            }
        }
        else {
            if (callback != nil) {
                callback(TGCurrencyUpdateResultSuccess);
            }
        }
    }
    else {
        if ([TGCurrency allObjects].count == 0) {
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"currency" ofType:@"json"];
            [self updateFromURL:[NSURL fileURLWithPath:filePath] error:&error];
        }

        if (error != nil) {
            if (callback != nil) {
                callback(TGCurrencyUpdateResultServerError);
            }
        }
        else {
            if (callback != nil) {
                callback(TGCurrencyUpdateResultNoInternet);
            }
        }
    }
}

+ (BOOL)updateFromURL:(NSURL *)URL error:(NSError **)error;
{
    NSData *currencyData = [NSData dataWithContentsOfURL:URL options:0 error:error];

    if (*error == nil) {
        NSDictionary *currencyRates = nil;
        @try {
            NSInputStream *inputStream = [NSInputStream inputStreamWithData:currencyData];
            [inputStream open];
            currencyRates = [NSJSONSerialization JSONObjectWithStream:inputStream options:0 error:error];
        }
        @catch (NSException *exception) {
            NSLog(@"Error parsing JSON");
        }

        if (*error == nil) {
            NSDate *nowDate = [NSDate date];
            RLMRealm *realm = [RLMRealm defaultRealm];

            for (NSString *code in currencyRates) {
                CGFloat rate = [currencyRates[code] floatValue];

                [realm transactionWithBlock:^{
                    TGCurrency *tgCurrency = [TGCurrency currencyForCode:code];

                    if (tgCurrency != nil) {
                        tgCurrency.value = rate;
                        tgCurrency.updateDate = nowDate;
                    }
                    else {
                        tgCurrency = [[TGCurrency alloc] init];

                        tgCurrency.code = code;
                        tgCurrency.value = rate;
                        tgCurrency.updateDate = nowDate;
                        
                        [realm addObject:tgCurrency];
                    }
                }];
            }
        }
    }

    return *error == nil;
}

@end
