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

@implementation TGMigrationManager

+ (void)migrate
{
    [RLMRealm setSchemaVersion:5
                forRealmAtPath:[RLMRealm defaultRealmPath]
            withMigrationBlock:^(RLMMigration *migration, NSUInteger oldSchemaVersion) {
        if (oldSchemaVersion < 1) {
            [ARAnalytics startTimingEvent:@"Migration 0 > 1"];

            [migration enumerateObjects:[TGRecognizedPrice className] block:^(RLMObject *oldObject, RLMObject *newObject) {
                NSString *currencyCode = oldObject[@"sourceCurrencyCode"];
                [migration enumerateObjects:[TGCurrency className] block:^(RLMObject *oldCurrency, RLMObject *newCurrency) {
                    if ([newCurrency[@"codeFrom"] isEqualToString:currencyCode]) {
                        newObject[@"sourceCurrency"] = newCurrency;
                    }
                }];
            }];

            [ARAnalytics finishTimingEvent:@"Migration 0 > 1"];
        }
        if (oldSchemaVersion < 2) {
            [ARAnalytics startTimingEvent:@"Migration 1 > 2"];

            [migration enumerateObjects:[TGRecognizedPrice className] block:^(RLMObject *oldObject, RLMObject *newObject) {
                newObject[@"rectData"] = [NSKeyedArchiver archivedDataWithRootObject:[NSValue valueWithCGRect:CGRectZero]];
            }];

            [ARAnalytics finishTimingEvent:@"Migration 1 > 2"];
        }
        if (oldSchemaVersion < 3) {
            [ARAnalytics startTimingEvent:@"Migration 2 > 3"];

            [migration enumerateObjects:[TGCurrency className] block:^(RLMObject *oldObject, RLMObject *newObject) {
                newObject[@"code"] = oldObject[@"codeFrom"];
            }];

            [ARAnalytics finishTimingEvent:@"Migration 2 > 3"];
        }
                
        if (oldSchemaVersion < 4) {
            [ARAnalytics startTimingEvent:@"Migration 3 > 4"];

            [migration enumerateObjects:[TGPriceImage className] block:^(RLMObject *oldObject, RLMObject *newObject) {
                newObject[@"tag"] = @"";
                newObject[@"locationData"] = [NSData data];
            }];

            [ARAnalytics finishTimingEvent:@"Migration 3 > 4"];
        }

        if (oldSchemaVersion < 5) {
            [ARAnalytics event:@"Migration 4 > 5"];
        }
    }];
    [RLMRealm migrateRealmAtPath:[RLMRealm defaultRealmPath]];
}

@end
