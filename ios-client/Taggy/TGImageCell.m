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

@interface TGImageCell ()

@property (nonatomic, weak) IBOutlet UIImageView *cellImageView;
@property (nonatomic, weak) IBOutlet UILabel *cellSourcePriceLabel;
@property (nonatomic, weak) IBOutlet UILabel *cellConvertedPriceLabel;

@end

@implementation TGImageCell

- (void)setPriceImage:(TGPriceImage *)priceImage
{
    if (priceImage != _priceImage) {
        _priceImage = priceImage;
        
        self.cellImageView.image = priceImage.thumbnail;

        TGRecognizedPrice *firstPrice = priceImage.prices.firstObject;
        self.cellSourcePriceLabel.text = [firstPrice formattedSourcePrice];
        self.cellConvertedPriceLabel.text = [firstPrice formattedConvertedPrice];
    }
}

@end
