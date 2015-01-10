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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

#ifdef DEBUG
    [ARAnalytics setupWithAnalytics:@{
                                      ARFlurryAPIKey : @"R28M5M82FH2X33XCQW4N",
                                      ARGoogleAnalyticsID : @"UA-9189602-6",
                                      ARYandexMobileMetricaAPIKey : @"30144",
                                      }];
#else
    [ARAnalytics setupWithAnalytics:@{
                                      ARFlurryAPIKey : @"6QPH2WFQCQRJHKPNHYTS",
                                      ARGoogleAnalyticsID : @"UA-9189602-7",
                                      ARYandexMobileMetricaAPIKey : @"31233",
                                      }];
#endif

    [TGMigrationManager migrate];

    [TGSettingsManager loadManager];
    
    [TGCurrencyManager updateWithCallback:nil];

#ifdef DEBUG
    [TGDataManager fillSample];
#endif

    return YES;
}

@end
