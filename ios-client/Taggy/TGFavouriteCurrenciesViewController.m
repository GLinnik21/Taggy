//
//  TGFavouriteCurrenciesViewController.m
//  Taggy
//
//  Created by Gleb Linkin on 06/05/15.
//  Copyright (c) 2015 Gleb Linkin. All rights reserved.
//

#import "TGFavouriteCurrenciesViewController.h"
#import "TGCurrencyViewController.h"

@interface TGFavouriteCurrenciesViewController ()

@property (nonatomic, strong) NSMutableArray *tableData;
@property (nonatomic, retain) UIActionSheet *deleteAllActionSheet;
@property (nonatomic, retain) UIActionSheet *sortActionSheet;

@end

@implementation TGFavouriteCurrenciesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *dismissButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self
                                                  action:@selector(dismiss)];
    self.navigationItem.leftBarButtonItem = dismissButton;
    
    self.tableView.editing = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    self.tableData = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"fav_currencies"]];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.tableData count] == 0) {
        [self setEditing:NO animated:YES];
        self.tableView.backgroundColor = [UIColor colorWithRed:(240 / 255.0)green:(240 / 255.0)blue:(240 / 255.0)alpha:1];
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        messageLabel.text = NSLocalizedString(@"no_fav", @"No favourite");
        messageLabel.textColor = [UIColor colorWithRed:(203 / 255.0)green:(203 / 255.0)blue:(203 / 255.0)alpha:1];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:25];
        [messageLabel sizeToFit];
        
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    else {
        self.tableView.backgroundView = nil;
        self.tableView.backgroundColor = nil;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    return [self.tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellID = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    
    // Configure the cell...
    cell.textLabel.text = self.tableData[indexPath.row];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", NSLocalizedString(self.tableData[indexPath.row], nil)];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath{
    [[NSUserDefaults standardUserDefaults] setObject:self.tableData forKey:@"fav_currencies"];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSString *stringToMove = self.tableData[sourceIndexPath.row];
    [self.tableData removeObjectAtIndex:sourceIndexPath.row];
    [self.tableData insertObject:stringToMove atIndex:destinationIndexPath.row];
    [[NSUserDefaults standardUserDefaults] setObject:self.tableData forKey:@"fav_currencies"];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView beginUpdates];
    [self.tableData removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView endUpdates];
}

- (IBAction)addFavCurrency:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TGCurrencyViewController *viewController =
    [storyboard instantiateViewControllerWithIdentifier:@"CurrenciesViewController"];
    
    UINavigationController *detailNavigationController =
    [[UINavigationController alloc] initWithRootViewController:viewController];
    
    UIBarButtonItem *dismissButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:viewController
                                                  action:@selector(dismiss)];
    viewController.navigationItem.leftBarButtonItem = dismissButton;
    [viewController.navigationItem.leftBarButtonItem setTintColor:[UIColor orangeColor]];
    [self presentViewController:detailNavigationController animated:YES completion:nil];
}

- (IBAction)deleteAll:(id)sender {
    self.deleteAllActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"fav_del_conf_question", nil)
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel")
                                               destructiveButtonTitle:NSLocalizedString(@"delete_all", @"Delete all")
                                                    otherButtonTitles:nil];
    
    [self.deleteAllActionSheet showInView:self.view];
}

- (IBAction)sortByAlphabeticalOrder:(id)sender {
    self.sortActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"fav_sort_conf_question", nil)
                                                 delegate:self
                                        cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel")
                                   destructiveButtonTitle:nil
                                        otherButtonTitles:NSLocalizedString(@"yes", @"Yes"), nil];
    
    [self.sortActionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == self.deleteAllActionSheet) {
        if (buttonIndex != actionSheet.cancelButtonIndex) {
            [self.tableData removeAllObjects];
            [self.tableView reloadData];
        }
    }else if (actionSheet == self.sortActionSheet) {
        if (buttonIndex != actionSheet.cancelButtonIndex) {
            self.tableData = [[self.tableData sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]mutableCopy];
            [self.tableView reloadData];
        }
    }
}

@end
