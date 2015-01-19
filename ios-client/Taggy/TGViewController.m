//
//  TGViewController.m
//  Taggy
//
//  Created by Gleb Linkin on 9/29/14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import "TGViewController.h"

#import <ARAnalytics/ARAnalytics.h>
#import "TGImageCell.h"
#import "TGDataManager.h"
#import "TGCurrencyManager.h"
#import "TGDetailViewController.h"
#import "TGSettingsManager.h"
#import "SVProgressHUD.h"
#import "NSDate+DateTools.h"

static NSString *const kTGImageCellId = @"ImageCell";

@interface TGViewController () <UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation TGViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] init];

    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(updateCurrency) forControlEvents:UIControlEventValueChanged];
    [refreshControl setBackgroundColor:[UIColor colorWithRed:(240/255.0) green:(240/255.0) blue:(240/255.0) alpha:1]];

    self.refreshControl = refreshControl;
}

- (void)updateCurrency
{
    __weak __typeof(self) weakSelf = self;
    [TGCurrencyManager updateWithCallback:^(TGCurrencyUpdateResult result) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;

        if (result == TGCurrencyUpdateResultSuccess) {
            [TGSettingsManager setObject:[NSDate date] forKey:kTGSettingsLastUpdateKey];

            [strongSelf.refreshControl endRefreshing];
        }
        else {
            [strongSelf.refreshControl endRefreshing];
            [SVProgressHUD setForegroundColor:[UIColor grayColor]];
            [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:(240/255.0) green:(240/255.0) blue:(240/255.0) alpha:1]];


            if (result == TGCurrencyUpdateResultNoInternet) {
                [SVProgressHUD setInfoImage:[UIImage imageNamed:@"internet"]];
                [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"NoInternet", @"No Internet connection")];
            }
            else if (result == TGCurrencyUpdateResultServerError) {
                [SVProgressHUD setInfoImage:[UIImage imageNamed:@"server"]];
                [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"ServerError", @"Server-side error")];
            }
        }
    }];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *updateDate = [defaults objectForKey:@"last_update"];
    NSString *title = [NSString stringWithFormat:NSLocalizedString(@"LastUpdate", nil), updateDate.timeAgoSinceNow];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor grayColor] forKey:NSForegroundColorAttributeName];
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
    self.refreshControl.attributedTitle = attributedTitle;
}

/*- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    if (editing) {
        [self.tableView setEditing:YES animated:YES];
        UIBarButtonItem *deleteAllButton = [[UIBarButtonItem alloc]
                                            initWithTitle:NSLocalizedString(@"delete_all", @"Delete all")
                                            style:UIBarButtonItemStyleBordered
                                            target:self
                                            action:@selector(deleteAllAction:)];
        self.navigationItem.leftBarButtonItem = deleteAllButton;
    }
    else {
        [self.tableView setEditing:NO animated:YES];
        self.navigationItem.leftBarButtonItem = nil;
    }
}*/

- (void)setEditing:(BOOL)flag animated:(BOOL)animated
{
    [super setEditing:flag animated:animated];
    if (flag == YES){
        [self.tableView setEditing:YES animated:YES];
        UIBarButtonItem *deleteAllButton = [[UIBarButtonItem alloc]
                                            initWithTitle:NSLocalizedString(@"delete_all", @"Delete all")
                                            style:UIBarButtonItemStyleBordered
                                            target:self
                                            action:@selector(deleteAllAction:)];
        self.navigationItem.leftBarButtonItem = deleteAllButton;
    }
    else {
        [self.tableView setEditing:NO animated:YES];
        self.navigationItem.leftBarButtonItem = nil;
    }
}


-(void)deleteAllAction:(UIBarButtonItem *)sender{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"conf_question", nil)
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel")
                                               destructiveButtonTitle:NSLocalizedString(@"delete_all", @"Delete all")
                                                    otherButtonTitles:nil];
    
    [actionSheet showInView:self.view];
    [self.tableView reloadData];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [TGDataManager deleteAllObjects];
        [self.tableView setEditing:NO animated:YES];
        self.navigationItem.leftBarButtonItem = nil;
        [self.tableView reloadData];
    }else if(buttonIndex == 1){
        [self.tableView setEditing:NO animated:YES];
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([TGDataManager recognizedImagesCount] == 0) {
        [self.tableView setEditing:NO animated:YES];
        [self.refreshControl removeFromSuperview];
        self.navigationItem.leftBarButtonItem = nil;
    } else
    {
        [self.tableView insertSubview:self.refreshControl atIndex:0];
    }
    
    if ([TGDataManager recognizedImagesCount] == 0) {
        self.tableView.backgroundColor = [UIColor colorWithRed:(240/255.0) green:(240/255.0) blue:(240/255.0) alpha:1];
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        messageLabel.text = NSLocalizedString(@"no_results", @"No results");
        messageLabel.textColor = [UIColor colorWithRed:(203/255.0) green:(203/255.0) blue:(203/255.0) alpha:1];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:25];
        [messageLabel sizeToFit];
        
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.navigationItem.rightBarButtonItem = nil;
    }
    else {
        self.tableView.backgroundView = nil;
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
        self.tableView.backgroundColor = nil;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    
    return [TGDataManager recognizedImagesCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TGImageCell *cell = [tableView dequeueReusableCellWithIdentifier:kTGImageCellId];

    cell.priceImage = [TGDataManager recognizedImageAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        TGImageCell *imageCell = (TGImageCell *)[tableView cellForRowAtIndexPath:indexPath];
        TGPriceImage *item = imageCell.priceImage;

        BOOL success = [TGDataManager removeRecognizedImage:item];
        if (success) {
            [ARAnalytics event:@"Item been deleted"];

            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationLeft];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if (indexPath != nil) {
        TGPriceImage *item = [TGDataManager recognizedImageAtIndex:indexPath.row];

        [ARAnalytics event:@"Item opened"];

        [segue.destinationViewController setDetail:item];
    }
}

@end
