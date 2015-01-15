//
//  TGDetailViewController.m
//  Taggy
//
//  Created by Gleb Linkin on 10/11/14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import "TGDetailViewController.h"
#import "TGPriceImage.h"
#import "TGPriceViewCell.h"

#import <Masonry/Masonry.h>

@interface TGDetailViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UIScrollView *imageScrollView;
@property (nonatomic, weak) UIImageView *imageView;

@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, weak) UILabel *sourcePriceDetailLabel;
@property (nonatomic, weak) UILabel *targetPriceDetailLabel;

@end

@implementation TGDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self configureViewController];
    [self reloadData];
}

- (void)configureViewController
{
    self.edgesForExtendedLayout = UIRectEdgeBottom;

    UIScrollView *imageScrollView = [[UIScrollView alloc] init];
    imageScrollView.clipsToBounds = YES;
    imageScrollView.scrollEnabled = NO;
    [self.view addSubview:imageScrollView];
    [imageScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(self.view).multipliedBy(0.6);
        make.top.equalTo(self.view);
        make.centerX.equalTo(self.view);
    }];
    self.imageScrollView = imageScrollView;

    UIImageView *imageView = [[UIImageView alloc] init];
    [self.imageScrollView addSubview:imageView];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.lessThanOrEqualTo(self.imageScrollView);
    }];
    self.imageView = imageView;

    UITableView *tableView = [[UITableView alloc] init];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.top.equalTo(self.imageScrollView.mas_bottom);
        make.bottom.equalTo(self.view);
    }];
    self.tableView = tableView;
}

- (void)configureImageViewWithImage:(UIImage *)image;
{
    CGFloat aspectRatio = image.size.width / image.size.height;
    self.imageView.image = image;

    if (aspectRatio > 1.0f) {
        [self.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(self.imageScrollView);
            make.width.equalTo(self.imageView.mas_height).multipliedBy(aspectRatio);
        }];
    }
    else {
        [self.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.imageScrollView);
            make.height.equalTo(self.imageView.mas_height).multipliedBy(1.0 / aspectRatio);
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath
                                animated:animated
                          scrollPosition:UITableViewScrollPositionTop];
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
}

- (void)reloadData
{
    if (self.detail == nil) {
        return;
    }

    [self configureImageViewWithImage:self.detail.image];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const kTGIdentifier = @"TGCELL";
    TGPriceViewCell *cell = (TGPriceViewCell *)[tableView dequeueReusableCellWithIdentifier:kTGIdentifier];
    if (cell == nil) {
        cell = [[TGPriceViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTGIdentifier];
    }

    TGRecognizedPrice *price = self.detail.prices[indexPath.row];
    cell.sourceValue = [price formattedSourcePrice];
    cell.convertedValue = [price formattedConvertedPrice];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TGRecognizedPrice *price = self.detail.prices[indexPath.row];
    self.imageView.image = [TGRecognizedPrice drawPrices:@[price] onImage:self.detail.image];

    /*CGRect rect = CGRectApplyAffineTransform(price.rect, CGAffineTransformTranslate(CGAffineTransformTranslate(CGAffineTransformIdentity, price.rect.size.width / 2, price.rect.size.height / 2), -self.imageScrollView.frame.size.width / 2, -self.imageScrollView.frame.size.height / 2));
    [self.imageScrollView setContentOffset:rect.origin animated:YES];*/
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.detail.prices.count;
}

@end
