//
//  TGDetailViewController.m
//  Taggy
//
//  Created by Gleb Linkin on 10/11/14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import "TGDetailViewController.h"
#import "TGPriceImage.h"

@interface TGDetailViewController()

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *sourcePriceDetailLabel;
@property (nonatomic, weak) IBOutlet UILabel *targetPriceDetailLabel;

@end

@implementation TGDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self reloadData];
}

- (void)reloadData
{
    if (self.detail == nil) {
        return;
    }

    TGRecognizedPrice *firstPrice = self.detail.prices.firstObject;

    self.navigationItem.title =
        [NSString stringWithFormat:@"%f (%@)", firstPrice.value, [self.detail localizedCaptureDate]];

    CGFloat convertedPrice = firstPrice.value * firstPrice.defaultCurrency.value;
    self.targetPriceDetailLabel.text = [NSString stringWithFormat:@"%f", convertedPrice];
    self.sourcePriceDetailLabel.text = [NSString stringWithFormat:@"%f", firstPrice.value];
    self.imageView.image = self.detail.image;

    self.scrollView.contentSize = self.scrollView.frame.size;
}

@end
