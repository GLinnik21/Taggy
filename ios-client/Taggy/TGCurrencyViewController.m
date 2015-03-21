//
//  TGCurrencyViewController.m
//  Taggy
//
//  Created by Gleb Linkin on 13/03/15.
//  Copyright (c) 2015 Gleb Linkin. All rights reserved.
//

#import "TGCurrencyViewController.h"
#import "TGCurrency.h"

@interface TGCurrencyViewController ()

@property (nonatomic, retain) NSIndexPath *checkedIndexPath;

@property (nonatomic, strong) NSMutableArray *codes;
@property (nonatomic, strong) NSMutableArray *rates;
@property (nonatomic, copy) NSArray *searchResults;

@end

@implementation TGCurrencyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.codes = [NSMutableArray array];
    for (TGCurrency *currency in [TGCurrency allObjects]) {
        [self.codes addObject:currency.code];
    }
    
    self.rates = [NSMutableArray array];
    for (TGCurrency *currency in [TGCurrency allObjects]) {
        [self.rates addObject:@(currency.value)];
    }

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchText];
    self.searchResults = [self.codes filteredArrayUsingPredicate:resultPredicate];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.searchResults count];
        
    } else {
        return [self.codes count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableHeaderFooterViewWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
    
    if([self.checkedIndexPath isEqual:indexPath]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
   // NSDictionary *dict = [NSDictionary dictionaryWithObjects:self.codes forKeys:self.rates];
    //NSLog(@"%@", dict);
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.textLabel.text = self.searchResults[indexPath.row];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", self.rates[indexPath.row]];
    }
    else {
        cell.textLabel.text = self.codes[indexPath.row];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", self.rates[indexPath.row]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.checkedIndexPath != nil) {
        UITableViewCell *uncheckCell = [tableView cellForRowAtIndexPath:self.checkedIndexPath];
        uncheckCell.accessoryType = UITableViewCellAccessoryNone;
    }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // Тут ключ должен быть в разных вьюхах разный.
    [defaults setObject:cell.textLabel.text forKey:@"country"];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    self.checkedIndexPath = indexPath;
}

@end
