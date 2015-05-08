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
#import "AFMInfoBanner.h"

static NSString *const kTGImageCellId = @"ImageCell";

@interface TGViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation TGViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.progressBar.progress = 0.0f;

    self.tableView.tableFooterView = [[UIView alloc] init];

    self.navigationItem.rightBarButtonItem = self.editButtonItem;

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(updateCurrency) forControlEvents:UIControlEventValueChanged];
    [refreshControl setBackgroundColor:[UIColor colorWithRed:(240 / 255.0)green:(240 / 255.0)blue:(240 / 255.0)alpha:1]];

    self.refreshControl = refreshControl;
}

- (void)updateCurrency
{
    BOOL history = [[TGSettingsManager objectForKey:kTGSettingsUpdateWithHisoryKey] boolValue];
    __weak __typeof(self) weakSelf = self;
    [TGCurrencyManager updateOne:YES history:history callback:^(TGCurrencyUpdateResult result) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;

        if (result != TGCurrencyUpdateResultSuccess) {
            [SVProgressHUD setForegroundColor:[UIColor grayColor]];
            [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:(240/255.0) green:(240/255.0) blue:(240/255.0) alpha:1]];

            if (result == TGCurrencyUpdateResultNoInternet) {
                [SVProgressHUD setInfoImage:[UIImage imageNamed:@"internet"]];
                [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"NoInternet", @"No Internet connection")];
                self.progressBar.progress = 0.0f;
            }
            else if (result == TGCurrencyUpdateResultServerError) {
                [SVProgressHUD setInfoImage:[UIImage imageNamed:@"server"]];
                [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"ServerError", @"Server-side error")];
                self.progressBar.progress = 0.0f;
            }
        }else{
            self.progressBar.progress = 0.0f;
            
            if ([[TGSettingsManager objectForKey:kTGSettingsUpdateWithHisoryKey] boolValue]== YES) {
                [AFMInfoBanner showAndHideWithText:NSLocalizedString(@"updated_with_history", @"Updated") style:AFMInfoBannerStyleInfo];
            }
            else{
                [AFMInfoBanner showAndHideWithText:NSLocalizedString(@"only_exchange_rates", @"Updated") style:AFMInfoBannerStyleInfo];
            }
        }

        [strongSelf.refreshControl endRefreshing];
    } progress:^(CGFloat progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progressBar setProgress:progress animated:YES];
        });
    }];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSDate *updateDate = [TGSettingsManager objectForKey:kTGSettingsLastUpdateKey];
    NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:updateDate];

    if (seconds < 60) {
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor grayColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSString *title = [NSString stringWithFormat:NSLocalizedString(@"just_now", @"Just now")];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title
                                                                              attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
    }
    else if ([TGSettingsManager objectForKey:kTGSettingsLastUpdateKey] == nil) {
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor grayColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSString *title = [NSString stringWithFormat:NSLocalizedString(@"LastUpdate", nil), [NSString stringWithFormat:NSLocalizedString(@"never", @"Never")]];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title
                                                                              attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
    }
    else {
        NSString *title = [NSString stringWithFormat:NSLocalizedString(@"LastUpdate", nil), updateDate.timeAgoSinceNow];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor grayColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title
                                                                              attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
    }
}

- (void)setEditing:(BOOL)flag animated:(BOOL)animated
{
    [super setEditing:flag animated:animated];
    if (flag) {
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

- (void)deleteAllAction:(UIBarButtonItem *)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"conf_question", nil)
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel")
                                               destructiveButtonTitle:NSLocalizedString(@"delete_all", @"Delete all")
                                                    otherButtonTitles:nil];

    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        [TGDataManager deleteAllObjects];
        [self setEditing:NO animated:YES];
        [self.tableView reloadData];
    }
    else {
        [self setEditing:NO animated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.tableView reloadData];
    [ARAnalytics pageView:@"Results"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([TGDataManager recognizedImagesCount] == 0) {
        [self setEditing:NO animated:YES];
        [self.refreshControl removeFromSuperview];
        self.navigationItem.leftBarButtonItem = nil;
        self.tableView.backgroundColor = [UIColor colorWithRed:(240 / 255.0)green:(240 / 255.0)blue:(240 / 255.0)alpha:1];
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        messageLabel.text = NSLocalizedString(@"no_results", @"No results");
        messageLabel.textColor = [UIColor colorWithRed:(203 / 255.0)green:(203 / 255.0)blue:(203 / 255.0)alpha:1];
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
        [self.tableView insertSubview:self.refreshControl atIndex:0];
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
