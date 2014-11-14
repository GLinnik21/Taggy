//
//  TGSettingsViewController.m
//  Taggy
//
//  Created by Gleb Linkin on 11/2/14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import "TGSettingsViewController.h"

@interface TGSettingsViewController () <IASKSettingsDelegate>

@end

@implementation TGSettingsViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        self.delegate = self;
    }
    return self;
}

- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
