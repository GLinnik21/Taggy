//
//  TGImageCell.m
//  Taggy
//
//  Created by Gleb Linkin on 10/10/14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import "TGImageCell.h"

#import "TGPriceImage.h"
#import "TGRecognizedPrice.h"
#import "NSDate+DateTools.h"


@interface TGImageCell ()

@property (nonatomic, weak) IBOutlet UIImageView *cellImageView;
@property (nonatomic, weak) IBOutlet UILabel *cellSourcePriceLabel;
@property (nonatomic, weak) IBOutlet UILabel *cellConvertedPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellProductLabel;

@end

@implementation TGImageCell

- (void)setPriceImage:(TGPriceImage *)priceImage
{
    if (priceImage != _priceImage) {
        _priceImage = priceImage;
        
        self.cellImageView.image = priceImage.thumbnail;
        
        
        NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:priceImage.captureDate];

        if (seconds < 60) {
            self.cellTimeLabel.text = NSLocalizedString(@"just_now", @"Just now");
        }else{
            self.cellTimeLabel.text = priceImage.captureDate.timeAgoSinceNow;;
        }
        TGRecognizedPrice *firstPrice = priceImage.prices.firstObject;
        self.cellSourcePriceLabel.text = [firstPrice formattedSourcePrice];
        self.cellConvertedPriceLabel.text = [firstPrice formattedConvertedPrice];
        
    }
}

@end
