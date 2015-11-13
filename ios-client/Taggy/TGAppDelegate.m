//
//  TGAppDelegate.m
//  Taggy
//
//  Created by Gleb Linkin on 9/29/14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import "TGAppDelegate.h"
#import <ARAnalytics/ARAnalytics.h>
#import "TGDataManager.h"
#import "TGCurrencyManager.h"
#import "TGMigrationManager.h"
#import "TGSettingsManager.h"

@interface TGAppDelegate ()

@end

@implementation TGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

#ifdef DEBUG
    [ARAnalytics setupWithAnalytics:@{
                                      ARFlurryAPIKey : @"R28M5M82FH2X33XCQW4N",
                                      ARGoogleAnalyticsID : @"UA-9189602-6",
                                      ARYandexMobileMetricaAPIKey : @"352ffba9-2296-4eac-90aa-82790deee634",
                                      }];
#else
    [ARAnalytics setupWithAnalytics:@{
                                      ARFlurryAPIKey : @"6QPH2WFQCQRJHKPNHYTS",
                                      ARGoogleAnalyticsID : @"UA-9189602-7",
                                      ARYandexMobileMetricaAPIKey : @"acd1baf4-8ef1-446d-8246-8264e71c1105",
                                      }];
#endif

    [TGMigrationManager migrate];

    [TGSettingsManager loadManager];

    [TGCurrencyManager initCurrencies];
    if ([[TGSettingsManager objectForKey:kTGSettingsAutoUpdateKey] boolValue]) {
        BOOL history = [[TGSettingsManager objectForKey:kTGSettingsUpdateWithHisoryKey] boolValue];
        [TGCurrencyManager updateOne:YES history:history callback:nil progress:nil];
    }

#ifdef DEBUG
    [TGDataManager fillSample];
#endif
    
    NSString *defaultPrefsFile = [[NSBundle mainBundle] pathForResource:@"defaultPrefs" ofType:@"plist"];
    NSDictionary *defaultPreferences = [NSDictionary dictionaryWithContentsOfFile:defaultPrefsFile];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultPreferences];
    
    [self.window setTintColor:[UIColor orangeColor]];

    UITabBarController *tabBar = (UITabBarController *)self.window.rootViewController;
    tabBar.selectedIndex = 1;
    
    return YES;
}

@end
