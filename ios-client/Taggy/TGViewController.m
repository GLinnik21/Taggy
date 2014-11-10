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
    self.navigationItem.title = @"Результаты";
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
    return [TGDataManager recognizedImagesCount];
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
