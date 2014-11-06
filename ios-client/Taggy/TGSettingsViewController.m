//
//  TGSettingsViewController.m
//  Taggy
//
//  Created by Gleb Linkin on 11/2/14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import "TGSettingsViewController.h"
#import <MessageUI/MessageUI.h>

#ifdef USES_IASK_STATIC_LIBRARY
#import "InAppSettingsKit/IASKSettingsReader.h"
#else
#import "IASKSettingsReader.h"
#endif

@interface TGSettingsViewController ()<UIPopoverControllerDelegate>
- (void)settingDidChange:(NSNotification*)notification;

@property (nonatomic) UIPopoverController* currentPopoverController;

@end

@implementation TGSettingsViewController

@synthesize appSettingsViewController, tabAppSettingsViewController;

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    self.appSettingsViewController = nil;
}

@end
