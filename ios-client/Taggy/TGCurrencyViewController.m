//
//  TGCurrencyViewController.m
//  Taggy
//
//  Created by Gleb Linkin on 13/03/15.
//  Copyright (c) 2015 Gleb Linkin. All rights reserved.
//

#import "TGCurrencyViewController.h"
#import "TGCurrency.h"

#import "TGSettingsManager.h"

@interface TGCurrencyViewController ()

@property (nonatomic, retain) NSIndexPath *checkedIndexPath;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

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

- (void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope
{
    NSString *lowerSearchString = [searchText lowercaseString];
    NSMutableArray *results = [NSMutableArray array];

    for (NSString *code in self.codes) {
        NSString *fullName = [[self fullNameForCode:code] lowercaseString];
        if ([fullName containsString:lowerSearchString]) {
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

- (NSString *)fullNameForCode:(NSString *)code
{
    return [NSString stringWithFormat:@"%@ (%@)", NSLocalizedString(code, nil), code];
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
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableHeaderFooterViewWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }

    NSString *rateId = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        rateId = self.searchResults[indexPath.row];
    }
    else {
        rateId = self.codes[indexPath.row];
    }
    NSNumber *rate = self.rates[rateId];

    cell.textLabel.text = [self fullNameForCode:rateId];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f", rate.floatValue];

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
        UITableViewCell *uncheckCell = [self.tableView cellForRowAtIndexPath:self.checkedIndexPath];
        uncheckCell.accessoryType = UITableViewCellAccessoryNone;
    }

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    NSString *fullName = cell.textLabel.text;
    NSString *code = [fullName substringWithRange:NSMakeRange(fullName.length - 4, 3)];
    
    [TGSettingsManager setObject:code forKey:self.settingsKey];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    self.checkedIndexPath = indexPath;

    [self.searchDisplayController setActive:NO animated:YES];
}

@end
