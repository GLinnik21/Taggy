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
#import "NSDate+DateTools.h"
#import "AFMInfoBanner.h"

#import "TGSettingsManager.h"
#import "TGCurrencyManager.h"

#import <ARAnalytics/ARAnalytics.h>

@interface TGSettingsViewController ()

@property (weak, nonatomic) IBOutlet UITableViewCell *sourceCurrencyCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *targetCurrencyCell;
@property (weak, nonatomic) IBOutlet UILabel *sourceCurrencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *targetCurrencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *privacyCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *siteCell;
@property (weak, nonatomic) IBOutlet UISwitch *auto_updateSwitch;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdateLabel;
@property (weak, nonatomic) IBOutlet UISwitch *update_with_historySwitch;
@property (weak, nonatomic) IBOutlet UITableViewCell *updateRateCell;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *updateRatesActivityIndicator;
@property (weak, nonatomic) IBOutlet UITableViewCell *updateHistoryCell;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *updateHistoryActivityIndicator;

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

    [ARAnalytics pageView:[NSString stringWithFormat:@"Settings %@", self.title]];

    [self fillLastUpdateLabel];

    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    self.privacyCell.hidden = [currSysVer compare:@"8.0" options:NSNumericSearch] != NSOrderedDescending;

    self.sourceCurrencyLabel.text = [[TGSettingsManager objectForKey:kTGSettingsSourceCurrencyKey] description];
    self.targetCurrencyLabel.text = [[TGSettingsManager objectForKey:kTGSettingsTargetCurrencyKey] description];
    
    [self.update_with_historySwitch setOn:[[TGSettingsManager objectForKey:kTGSettingsUpdateWithHisoryKey] boolValue]
                         animated:NO];
    [self.auto_updateSwitch setOn:[[TGSettingsManager objectForKey:kTGSettingsAutoUpdateKey] boolValue]
                         animated:NO];
}

- (void)fillLastUpdateLabel
{
    NSDate *updateDate = [TGSettingsManager objectForKey:kTGSettingsLastUpdateKey];
    NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:updateDate];

    if (seconds < 60) {
        self.lastUpdateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LastUpdate", nil), [NSString stringWithFormat:NSLocalizedString(@"just_now", @"Just now")]];
    }
    else if ([TGSettingsManager objectForKey:kTGSettingsLastUpdateKey] == nil) {
        self.lastUpdateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LastUpdate", nil), [NSString stringWithFormat:NSLocalizedString(@"never", @"Never")]];
    }
    else {
        self.lastUpdateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LastUpdate", nil), updateDate.timeAgoSinceNow];
    }
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
    
    if (theCellClicked == self.updateRateCell) {
        [self.updateRatesActivityIndicator startAnimating];

        __weak __typeof(self) weakSelf = self;
        [TGCurrencyManager updateOne:YES history:NO callback:^(TGCurrencyUpdateResult result) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf fillLastUpdateLabel];
            [strongSelf.updateRatesActivityIndicator stopAnimating];
        } progress:nil];
    }
    
    if (theCellClicked == self.updateHistoryCell) {
        [self.updateHistoryActivityIndicator startAnimating];

        __weak __typeof(self) weakSelf = self;
        [TGCurrencyManager updateOne:NO history:YES callback:^(TGCurrencyUpdateResult result) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf fillLastUpdateLabel];
            [strongSelf.updateHistoryActivityIndicator stopAnimating];
        } progress:nil];
    }
}

- (IBAction)auto_updateSwitchAction:(id)sender
{
    BOOL autoUpdate = [[TGSettingsManager objectForKey:kTGSettingsAutoUpdateKey] boolValue];
    autoUpdate = autoUpdate == NO;
    [TGSettingsManager setObject:@(autoUpdate) forKey:kTGSettingsAutoUpdateKey];
}

- (IBAction)update_with_historySwitchAction:(id)sender {
    BOOL updateWithHistory = [[TGSettingsManager objectForKey:kTGSettingsUpdateWithHisoryKey] boolValue];
    updateWithHistory = updateWithHistory == NO;
    [TGSettingsManager setObject:@(updateWithHistory) forKey:kTGSettingsUpdateWithHisoryKey];

}

@end
