//
//  TGPriceViewCell.m
//  Taggy
//
//  Created by Nikolay Volosatov on 29.12.14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import "TGPriceViewCell.h"

#import <Masonry/Masonry.h>

static CGFloat const kTGSpaceMargin = 10.0f;

@interface TGPriceViewCell ()

@property (nonatomic, weak) UILabel *sourceTextLabel;
@property (nonatomic, weak) UILabel *separatorLabel;
@property (nonatomic, weak) UILabel *convertedTextLabel;
@property (nonatomic, weak) UIButton *editButton;

@end

@implementation TGPriceViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self != nil) {
        UILabel *sourceLabel = [[UILabel alloc] init];
        sourceLabel.textAlignment = NSTextAlignmentRight;
        sourceLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:sourceLabel];
        _sourceTextLabel = sourceLabel;

        UILabel *separatorLabel = [[UILabel alloc] init];
        separatorLabel.text = @"-";
        [self.contentView addSubview:separatorLabel];
        _separatorLabel = separatorLabel;

        UILabel *targetLabel = [[UILabel alloc] init];
        targetLabel.textAlignment = NSTextAlignmentLeft;
        targetLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:targetLabel];
        _convertedTextLabel = targetLabel;

        UIButton *editButton = [[UIButton alloc] init];
        [editButton setBackgroundImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
        [editButton setTintColor:[UIColor orangeColor]];
        [self.contentView addSubview:editButton];
        _editButton = editButton;
        
        [self configureViews];
    }
    return self;
}

- (void)configureViews
{
    [self.separatorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];

    [self.convertedTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self.separatorLabel.mas_right).offset(kTGSpaceMargin);
        make.right.equalTo(self.editButton.mas_left);
    }];

    [self.sourceTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self.separatorLabel.mas_left).offset(-kTGSpaceMargin);
        make.left.equalTo(self).offset(kTGSpaceMargin);
    }];
    
    [self.editButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(20);
        make.centerY.equalTo(self);
        make.right.equalTo(self).offset(-kTGSpaceMargin);
    }];
}

- (void)setSourceValue:(NSString *)sourceValue
{
    if ([sourceValue isEqualToString:_sourceValue] == NO) {
        _sourceValue = [sourceValue copy];

        self.sourceTextLabel.text = sourceValue;
    }
}

- (void)setConvertedValue:(NSString *)convertedValue
{
    if ([convertedValue isEqualToString:_convertedValue] == NO) {
        _convertedValue = [convertedValue copy];

        self.convertedTextLabel.text = convertedValue;
    }
}

- (void)setAdView:(UIView *)adView
{
    if (_adView != adView) {
        if (_adView != nil) {
            [_adView removeFromSuperview];
        }
        if (adView != nil) {
            [self addSubview:adView];
        }
        _adView = adView;

        BOOL isAd = adView != nil;
        self.separatorLabel.hidden = isAd;
        self.sourceTextLabel.hidden = isAd;
        self.convertedTextLabel.hidden = isAd;
        self.editButton.hidden = isAd;

        self.selectionStyle = isAd ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleDefault;
    }
}

@end
