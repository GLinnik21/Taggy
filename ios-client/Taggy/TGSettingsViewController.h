//
//  TGSettingsViewController.h
//  Taggy
//
//  Created by Gleb Linkin on 11/2/14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import <UIKit/UIKit.h>
#if USES_IASK_STATIC_LIBRARY
#import "InAppSettingsKit/IASKAppSettingsViewController.h"
#else
#import "IASKAppSettingsViewController.h"
#endif


@interface TGSettingsViewController : UIViewController <IASKSettingsDelegate, UITextViewDelegate>{
    IASKAppSettingsViewController *appSettingsViewController;
    IASKAppSettingsViewController *tabAppSettingsViewController;
}

@property (nonatomic, retain) IASKAppSettingsViewController *appSettingsViewController;
@property (nonatomic, retain) IBOutlet IASKAppSettingsViewController *tabAppSettingsViewController;

- (IBAction)showSettingsPush:(id)sender;
- (IBAction)showSettingsModal:(id)sender;


@end
