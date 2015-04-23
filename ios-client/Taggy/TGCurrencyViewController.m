//
//  TGCurrencyViewController.m
//  Taggy
//
//  Created by Gleb Linkin on 13/03/15.
//  Copyright (c) 2015 Gleb Linkin. All rights reserved.
//

#import "TGCurrencyViewController.h"
#import "TGCurrency.h"
#import "TGcurrencyCell.h"

#import "TGSettingsManager.h"

@interface TGCurrencyViewController ()

@property (nonatomic, retain) NSIndexPath *checkedIndexPath;

@property (nonatomic, strong) NSArray *codes;
@property (nonatomic, strong) NSMutableDictionary *rates;
@property (nonatomic, copy) NSArray *searchResults;

@end

@implementation TGCurrencyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.rates = [NSMutableDictionary dictionary];
    for (TGCurrency *currency in [TGCurrency allObjects]) {
        self.rates[currency.code] = @(currency.value);
    }
    self.codes = [self.rates.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope
{
    NSString *lowerSearchString = [searchText lowercaseString];
    NSMutableArray *results = [NSMutableArray array];

    for (NSString *code in self.codes) {
        NSString *fullName = [[self FullNameForCode:code] lowercaseString];
        NSString *ISO = [[self ISOForCode:code] lowercaseString];
        if ([ISO rangeOfString:lowerSearchString].length != 0 ||
            [fullName rangeOfString:lowerSearchString].length != 0) {
            [results addObject:code];
        }
    }

    self.searchResults = [results copy];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
    shouldReloadTableForSearchString:(NSString *)searchString
{
    NSInteger scopeIndex = self.searchDisplayController.searchBar.selectedScopeButtonIndex;
    NSString *scope = self.searchDisplayController.searchBar.scopeButtonTitles[scopeIndex];

    [self filterContentForSearchText:searchString scope:scope];

    return YES;
}

- (NSString *)FullNameForCode:(NSString *)code
{
    return [NSString stringWithFormat:@"%@", NSLocalizedString(code, nil)];
}

- (NSString *)ISOForCode:(NSString *)code
{
    return [NSString stringWithFormat:@"%@", code];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return self.searchResults.count;
    }
    else {
        return self.rates.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"currencyCell";
    TGcurrencyCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];

    if (cell == nil) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
    }

    NSString *rateId = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        rateId = self.searchResults[indexPath.row];
    }
    else {
        rateId = self.codes[indexPath.row];
    }
    NSNumber *rate = self.rates[rateId];

    cell.ISOLabel.text = rateId;
    cell.RateLabel.text = [NSString stringWithFormat:@"%.2f", rate.floatValue];
    cell.FullLabel.text = [NSString stringWithFormat:@"%@", NSLocalizedString(rateId, nil)];

    if ([[TGSettingsManager objectForKey:self.settingsKey] isEqualToString:rateId]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        if (tableView != self.searchDisplayController.searchResultsTableView) {
            self.checkedIndexPath = indexPath;
        }
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (self.checkedIndexPath != nil) {
        TGcurrencyCell *uncheckCell = [self.tableView cellForRowAtIndexPath:self.checkedIndexPath];
        uncheckCell.accessoryType = UITableViewCellAccessoryNone;
    }

    TGcurrencyCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    NSString *code = cell.ISOLabel.text;

    [TGSettingsManager setObject:code forKey:self.settingsKey];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    self.checkedIndexPath = indexPath;

    [self.searchDisplayController setActive:NO animated:YES];
}

@end
