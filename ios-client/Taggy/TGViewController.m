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
#import "TGDetailViewController.h"

static NSString *const kTGImageCellId = @"ImageCell";

@interface TGViewController () <UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation TGViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    if (editing) {
        [self.tableView setEditing:YES animated:YES];
    }
    else {
        [self.tableView setEditing:NO animated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"Rows: %ld", (long)[TGDataManager recognizedImagesCount]);
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
        return [TGDataManager recognizedImagesCount];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TGImageCell *cell = [tableView dequeueReusableCellWithIdentifier:kTGImageCellId];
    
    TGPriceImage *item = [TGDataManager recognizedImageAtIndex:indexPath.row];
    cell.cellImageView.image = item.thumbnail;

    TGRecognizedPrice *firstPrice = item.prices.firstObject;
    cell.cellSourcePriceLabel.text = [firstPrice formattedSourcePrice];
    cell.cellConvertedPriceLabel.text = [firstPrice formattedConvertedPrice];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    TGPriceImage *item = [TGDataManager recognizedImageAtIndex:indexPath.row];

    [ARAnalytics event:@"Item been deleted"];

    [TGDataManager removeRecognizedImage:item];

    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
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
