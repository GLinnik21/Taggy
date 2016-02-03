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
#import "WYPopoverController.h"
#import "TGEditViewController.h"

#import <Masonry/Masonry.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <ARAnalytics/ARAnalytics.h>

static NSInteger const kTGAdRowIndex = 1;

@interface TGDetailViewController () <UITableViewDelegate, UITableViewDataSource, WYPopoverControllerDelegate>
{
    WYPopoverController* popoverController;
}

@property (nonatomic, weak) UIScrollView *imageScrollView;
@property (nonatomic, weak) UIImageView *imageView;

@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, weak) UILabel *sourcePriceDetailLabel;
@property (nonatomic, weak) UILabel *targetPriceDetailLabel;
@property (weak, nonatomic) IBOutlet UINavigationItem *resultNavigationBar;
@property (nonatomic, strong) UIButton *editButton;

@end

@implementation TGDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImage *tagImage = [UIImage imageNamed:@"tag"];
    CGRect frameimg = CGRectMake(30, 30, tagImage.size.width, tagImage.size.height);
    UIButton *tagButton = [[UIButton alloc] initWithFrame:frameimg];
    [tagButton setBackgroundImage:tagImage forState:UIControlStateNormal];
    [tagButton addTarget:self action:@selector(saveTag) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *tagBarButton = [[UIBarButtonItem alloc] initWithCustomView:tagButton];
    self.resultNavigationBar.rightBarButtonItem = tagBarButton;

    [self configureViewController];
    [self reloadData];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
        make.centerX.equalTo(self.view);
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
            make.height.equalTo(self.imageView.mas_width).multipliedBy(1.0 / aspectRatio);
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [ARAnalytics pageView:@"Result"];

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

    if (indexPath.row == kTGAdRowIndex || (indexPath.row < kTGAdRowIndex && self.detail.prices.count == 0)) {
        GADAdSize size = kGADAdSizeBanner;
        CGPoint offset = {(CGRectGetWidth(self.view.frame) - size.size.width) * 0.5f, 0};
        GADBannerView *bannerView = [[GADBannerView alloc] initWithAdSize:size origin:offset];

        bannerView.adUnitID = @"ca-app-pub-4888565019454310/2060506587";
        bannerView.rootViewController = self;
        cell.adView = bannerView;

        GADRequest *request = [GADRequest request];
        request.testDevices = @[
            @"15b40275f1bcd61e4de764a6c44229a6aaf58783", // Gleb iPad
            @"7f354da3b0a2cd6d85c1afe5630a59a9bcbb709c", // Yndx 6
            @"48cd3860fedb69529c8254e94603813ffdb6505c", // Yndx 6+
            @"b2c4ec43071fab1ab34f2cb9c68aa55dd5b533b2", // Yndx iPad
        ];

        [bannerView loadRequest:request];
    }
    else {
        TGRecognizedPrice *price = self.detail.prices[indexPath.row - (indexPath.row < kTGAdRowIndex ? 0 : 1)];
        cell.adView = nil;
        cell.sourceValue = [price formattedSourcePrice];
        cell.convertedValue = [price formattedConvertedPrice];
        self.editButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
        [self.editButton setImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
        cell.accessoryView = self.editButton;
        [self.editButton addTarget:self
                   action:@selector(editAction)
         forControlEvents:UIControlEventTouchUpInside];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isAd = indexPath.row == kTGAdRowIndex || (indexPath.row < kTGAdRowIndex && self.detail.prices.count == 0);
    return isAd ? kGADAdSizeBanner.size.height : tableView.rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == kTGAdRowIndex) {
        return;
    }

    TGRecognizedPrice *price = self.detail.prices[indexPath.row - (indexPath.row < kTGAdRowIndex ? 0 : 1)];
    self.imageView.image = [TGRecognizedPrice drawPrices:@[ price ] onImage:self.detail.image];

    /*CGRect rect = CGRectApplyAffineTransform(price.rect, CGAffineTransformTranslate(CGAffineTransformTranslate(CGAffineTransformIdentity, price.rect.size.width / 2, price.rect.size.height / 2), -self.imageScrollView.frame.size.width / 2, -self.imageScrollView.frame.size.height / 2));
    [self.imageScrollView setContentOffset:rect.origin animated:YES];*/
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.detail.prices.count + 1;
}

- (void)editAction
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TGEditViewController *viewController =
    [storyboard instantiateViewControllerWithIdentifier:@"EditViewContriller"];
    popoverController = [[WYPopoverController alloc] initWithContentViewController:viewController];
    
    UIBarButtonItem *dismissButton =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                      target:viewController
                                                      action:@selector(dismiss)];
    viewController.navigationItem.rightBarButtonItem = dismissButton;
    popoverController.delegate = self;
    [popoverController presentPopoverFromRect:self.editButton.bounds
                                       inView:self.editButton
                     permittedArrowDirections:WYPopoverArrowDirectionAny
                                     animated:YES
                                      options:WYPopoverAnimationOptionFadeWithScale];
}

- (void)saveTag
{
    UIAlertView *tagSaveAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"save_tag", @"Save?")
                                                           message:NSLocalizedString(@"save_tag_mess", nil)
                                                          delegate:self
                                                 cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel")
                                                 otherButtonTitles:@"OK", nil];
    tagSaveAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [tagSaveAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *test = [[alertView textFieldAtIndex:0] text];
    if (buttonIndex == 1) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        self.detail.tag = test;
        [realm commitWriteTransaction];
    }
}

@end
