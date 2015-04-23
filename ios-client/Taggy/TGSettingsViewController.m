//
//  TGSettingsViewController.m
//  Taggy
//
//  Created by Gleb Linkin on 12/03/15.
//  Copyright (c) 2015 Gleb Linkin. All rights reserved.
//

#import "TGSettingsViewController.h"
#import "TGCurrencyViewController.h"
#import "TGViewController.h"

#import "TGSettingsManager.h"

@interface TGSettingsViewController ()

@property (weak, nonatomic) IBOutlet UITableViewCell *sourceCurrencyCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *targetCurrencyCell;
@property (weak, nonatomic) IBOutlet UILabel *sourceCurrencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *targetCurrencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *privacyCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *siteCell;
@property (weak, nonatomic) IBOutlet UISwitch *auto_updateSwitch;

@end

@implementation TGSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.versionLabel.text = [[TGSettingsManager objectForKey:kTGSettingsVersionKey] description];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    self.privacyCell.hidden = [currSysVer compare:@"8.0" options:NSNumericSearch] != NSOrderedDescending;

    self.sourceCurrencyLabel.text = [[TGSettingsManager objectForKey:kTGSettingsSourceCurrencyKey] description];
    self.targetCurrencyLabel.text = [[TGSettingsManager objectForKey:kTGSettingsTargetCurrencyKey] description];

    [self.auto_updateSwitch setOn:[[TGSettingsManager objectForKey:kTGSettingsAutoUpdateKey] boolValue]
                         animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 && indexPath.section == 0 && self.versionLabel == nil) {
        NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
        if ([currSysVer compare:@"8.0" options:NSNumericSearch] != NSOrderedDescending) {
            return 0.0;
        }
    }

    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *theCellClicked = [self.tableView cellForRowAtIndexPath:indexPath];
    if (theCellClicked == self.siteCell) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://taggy.by"]];
    }

    if (theCellClicked == self.privacyCell) {
        if (&UIApplicationOpenSettingsURLString != NULL) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }

    if (theCellClicked == self.sourceCurrencyCell) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        TGCurrencyViewController *currency =
            [storyboard instantiateViewControllerWithIdentifier:@"CurrenciesViewController"];
        currency.settingsKey = kTGSettingsSourceCurrencyKey;
        [self.navigationController pushViewController:currency animated:YES];
    }

    if (theCellClicked == self.targetCurrencyCell) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        TGCurrencyViewController *currency =
            [storyboard instantiateViewControllerWithIdentifier:@"CurrenciesViewController"];
        currency.settingsKey = kTGSettingsTargetCurrencyKey;
        [self.navigationController pushViewController:currency animated:YES];
    }
}

- (IBAction)auto_updateSwitchAction:(id)sender
{
    BOOL autoUpdate = [[TGSettingsManager objectForKey:kTGSettingsAutoUpdateKey] boolValue];
    autoUpdate = autoUpdate == NO;
    [TGSettingsManager setObject:@(autoUpdate) forKey:kTGSettingsAutoUpdateKey];
}

@end
