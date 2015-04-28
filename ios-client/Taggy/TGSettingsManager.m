//
//  TGSettingsManager.m
//  Taggy
//
//  Created by Nikolay Volosatov on 10.01.15.
//  Copyright (c) 2015 Gleb Linkin. All rights reserved.
//

#import "TGSettingsManager.h"

NSString *const kTGSettingsVersionKey = @"version";
NSString *const kTGSettingsAutoUpdateKey = @"auto_update";
NSString *const kTGSettingsUpdateWithHisoryKey = @"update_with_history";
NSString *const kTGSettingsSourceCurrencyKey = @"country";
NSString *const kTGSettingsTargetCurrencyKey = @"transf";
NSString *const kTGSettingsLastUpdateKey = @"last_update";
NSString *const kTGSettingsBorderDetectionKey = @"border_detection";

static NSString *const kTGInfoVersion = @"CFBundleShortVersionString";

@implementation TGSettingsManager

+ (void)loadManager
{
    [[self class] registerDefaults];
    [[self class] updateAppVersion];
}

+ (void)registerDefaults
{
    NSDictionary *settings = [[self class] settingsFromBundle];
    [[NSUserDefaults standardUserDefaults] registerDefaults:settings];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary *)settingsFromBundle
{
    NSURL *settingsBundleURL = [[NSBundle mainBundle] URLForResource:@"Settings" withExtension:@"bundle"];
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];

    NSURL *settingPlistURL = [settingsBundleURL URLByAppendingPathComponent:@"Root.plist"];
    NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfURL:settingPlistURL];
    NSArray *prefSpecifierArray = settingsDict[@"PreferenceSpecifiers"];
    for (NSDictionary *prefItem in prefSpecifierArray) {
        NSString *prefItemKey = prefItem[@"Key"];
        NSString *prefItemDefaultValue = prefItem[@"DefaultValue"];
        if (prefItemKey != nil && prefItemDefaultValue != nil) {
            settings[prefItemKey] = prefItemDefaultValue;
        }
    }

    settings[kTGSettingsBorderDetectionKey] = @(YES);

    return settings;
}

+ (void)updateAppVersion
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];

    NSString *version = [infoDictionary objectForKey:kTGInfoVersion];

    [[NSUserDefaults standardUserDefaults] setObject:version forKey:kTGSettingsVersionKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id)objectForKey:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+ (void)setObject:(id)value forKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
