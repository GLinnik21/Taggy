//
//  TGSettingsManager.h
//  Taggy
//
//  Created by Nikolay Volosatov on 10.01.15.
//  Copyright (c) 2015 Gleb Linkin. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kTGSettingsVersionKey;
extern NSString *const kTGSettingsAutoUpdateKey;
extern NSString *const kTGSettingsSourceCurrencyKey;
extern NSString *const kTGSettingsTargetCurrencyKey;
extern NSString *const kTGSettingsLastUpdateKey;

@interface TGSettingsManager : NSObject

+ (void)loadManager;

+ (id)objectForKey:(NSString *)key;
+ (void)setObject:(id)value forKey:(NSString *)key;

@end
