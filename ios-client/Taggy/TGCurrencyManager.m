//
//  TGCurrencyManager.m
//  Taggy
//
//  Created by Nikolay Volosatov on 10.11.14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import "TGCurrencyManager.h"
#import "TGSettingsManager.h"

#import <Realm/Realm.h>
#import <Reachability/Reachability.h>
#import "TGCurrency.h"

static NSString *const kTGCurrencyLink = @"http://api.taggy.by/rates";
static NSString *const kTGCurrencyHistoryLink = @"http://api.taggy.by/history/%lu/%lu";

static NSTimeInterval const kTGMonth = 30 * 24 * 60 * 60;
static NSTimeInterval const kTGOneUpdate = 60 * 60;

@implementation TGCurrencyManager

+ (void)initCurrencies
{
    if ([TGCurrency allObjects].count == 0) {
        [[self class] updateWithCallback:nil offline:YES];
    }
}

+ (void)updateWithCallback:(TGCurrencyUpdateCallback)callback
{
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [[weakSelf class] updateWithCallback:callback offline:NO];
    });
}

+ (void)updateWithCallback:(TGCurrencyUpdateCallback)callback offline:(BOOL)offline
{
    NSError *error = nil;
    NSURL *URL = [NSURL URLWithString:kTGCurrencyLink];
    Reachability *apiReachable = [Reachability reachabilityWithHostname:URL.host];

    if (offline == NO && [apiReachable isReachable]) {
        [self updateFromURL:URL error:&error];
        if (error == nil) {
            [self updateHistoryInfoWithError:&error];
        }

        if (error != nil) {
            if (callback != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    callback(TGCurrencyUpdateResultServerError);
                });
            }
        }
        else {
            [TGSettingsManager setObject:[NSDate date] forKey:kTGSettingsLastUpdateKey];
            if (callback != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    callback(TGCurrencyUpdateResultSuccess);
                });
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    callback(TGCurrencyUpdateResultServerError);
                });
            }
        }
        else {
            if (callback != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    callback(TGCurrencyUpdateResultNoInternet);
                });
            }
        }
    }
}

+ (BOOL)updateFromURL:(NSURL *)URL error:(NSError **)error
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
            DDLogError(@"Error parsing JSON");
        }

        if (*error == nil) {
            [[self class] updateCurrencyDataFromDictionary:currencyRates];
        }
    }

    return *error == nil;
}

+ (void)updateCurrencyDataFromDictionary:(NSDictionary *)currencyRates
{
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

+ (BOOL)updateHistoryInfoWithError:(NSError **)error
{
    NSDate *maximumDate = [NSDate date];
    for (TGCurrency *currency in [TGCurrency allObjects]) {
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:-kTGMonth];
        for (TGCurrencyHistoryItem *item in currency.historyItems) {
            if ([date compare:item.date] == NSOrderedAscending) {
                date = item.date;
            }
        }
        if ([maximumDate compare:date] == NSOrderedDescending) {
            maximumDate = date;
        }
    }

    NSInteger from = 0;
    NSInteger count = ceilf(ABS(maximumDate.timeIntervalSinceNow) / kTGOneUpdate);

    if (count == 0) {
        return YES;
    }

    NSString *link = [NSString stringWithFormat:kTGCurrencyHistoryLink, (unsigned long)from, (unsigned long)count];
    NSURL *URL = [NSURL URLWithString:link];
    NSData *currencyData = [NSData dataWithContentsOfURL:URL options:0 error:error];

    if (*error == nil) {
        NSDictionary *currencies = nil;
        @try {
            NSInputStream *inputStream = [NSInputStream inputStreamWithData:currencyData];
            [inputStream open];
            currencies = [NSJSONSerialization JSONObjectWithStream:inputStream options:0 error:error];
        }
        @catch (NSException *exception) {
            DDLogError(@"Error parsing JSON");
        }

        if (*error == nil) {
            [[self class] updateCurrencyHistoryWithDictionary:currencies];
        }
    }

    return *error == nil;
}

+ (void)updateCurrencyHistoryWithDictionary:(NSDictionary *)currencies
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    for (NSString *code in currencies) {
        RLMRealm *realm = [RLMRealm defaultRealm];

        NSDictionary *rates = currencies[code];

        [realm transactionWithBlock:^{
            TGCurrency *tgCurrency = [TGCurrency currencyForCode:code];

            if (tgCurrency == nil) return;

            TGCurrencyHistoryItem *lastItem = [tgCurrency.historyItems sortedResultsUsingProperty:@"date" ascending:NO].firstObject;

            for (NSString *dateString in rates) {
                NSDate *date = [formatter dateFromString:dateString];

                if (lastItem == nil || [date compare:lastItem.date] == NSOrderedDescending) {
                    TGCurrencyHistoryItem *item = [[TGCurrencyHistoryItem alloc] init];
                    item.date = date;
                    item.value = [rates[dateString] floatValue];

                    [tgCurrency.historyItems addObject:item];
                }
            }
        }];

        [realm invalidate];
    }
}

@end
