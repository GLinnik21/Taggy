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
#import "TGRecognizedPrice.h"

@implementation TGMigrationManager

+ (void)migrate
{
    [RLMRealm setSchemaVersion:1 withMigrationBlock:^(RLMMigration *migration, NSUInteger oldSchemaVersion) {
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
    }];
    [RLMRealm migrateRealmAtPath:[RLMRealm defaultRealmPath]];
}

@end
