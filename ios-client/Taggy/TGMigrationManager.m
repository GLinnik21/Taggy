//
//  TGMigrationManager.m
//  Taggy
//
//  Created by Nikolay Volosatov on 10.11.14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import "TGMigrationManager.h"
#import <Realm/Realm.h>
#import <ARAnalytics/ARAnalytics.h>

#import "TGCurrency.h"
#import "TGPriceImage.h"
#import "TGRecognizedPrice.h"
#import "TGFavouriteCurrencies.h"

static NSUInteger const kTGSchemaVersion = 5;

@implementation TGMigrationManager

+ (void)migrate
{
    [RLMRealmConfiguration defaultConfiguration].migrationBlock =
        ^(RLMMigration *migration, uint64_t oldSchemaVersion) {
            [self migrateAll:migration oldVer:oldSchemaVersion newVer:kTGSchemaVersion];
        };
    [RLMRealmConfiguration defaultConfiguration].schemaVersion = kTGSchemaVersion;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

+ (void)migrateAll:(RLMMigration *)migration oldVer:(NSUInteger)oldVer newVer:(NSUInteger)newVer
{
    for (NSUInteger fromVer = oldVer; fromVer < newVer; ++fromVer) {
        NSString *methodName = [NSString stringWithFormat:@"migrateTo%lu:", fromVer + 1];
        SEL method = NSSelectorFromString(methodName);

        [ARAnalytics startTimingEvent:methodName];

        BOOL success = YES;
        if ([self respondsToSelector:method]) {
            [self performSelector:method withObject:migration];
        }
        else {
            success = NO;
            DDLogWarn(@"Not found migration for version %lu -> %lu", fromVer, fromVer + 1);
        }

        [ARAnalytics finishTimingEvent:methodName
                        withProperties:@{ @"ok" : (success ? @"true" : @"false") }];
    }
}

#pragma clang diagnostic pop

+ (void)migrateTo1:(RLMMigration *)migration
{
    [migration enumerateObjects:[TGRecognizedPrice className] block:^(RLMObject *oldObject, RLMObject *newObject) {
        NSString *currencyCode = oldObject[@"sourceCurrencyCode"];
        [migration enumerateObjects:[TGCurrency className] block:^(RLMObject *oldCurrency, RLMObject *newCurrency) {
            if ([newCurrency[@"codeFrom"] isEqualToString:currencyCode]) {
                newObject[@"sourceCurrency"] = newCurrency;
            }
        }];
    }];
}

+ (void)migrateTo2:(RLMMigration *)migration
{
    [migration enumerateObjects:[TGRecognizedPrice className] block:^(RLMObject *oldObject, RLMObject *newObject) {
        newObject[@"rectData"] = [NSKeyedArchiver archivedDataWithRootObject:[NSValue valueWithCGRect:CGRectZero]];
    }];
}

+ (void)migrateTo3:(RLMMigration *)migration
{
    [migration enumerateObjects:[TGCurrency className] block:^(RLMObject *oldObject, RLMObject *newObject) {
        newObject[@"code"] = oldObject[@"codeFrom"];
    }];
}

+ (void)migrateTo4:(RLMMigration *)migration
{
    [migration enumerateObjects:[TGPriceImage className] block:^(RLMObject *oldObject, RLMObject *newObject) {
        newObject[@"tag"] = @"";
        newObject[@"locationData"] = [NSData data];
    }];
}

+ (void)migrateTo5:(RLMMigration *)migration
{
}

@end
