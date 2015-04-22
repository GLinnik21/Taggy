//
//  TGPriceViewCell.h
//  Taggy
//
//  Created by Nikolay Volosatov on 29.12.14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TGPriceViewCell : UITableViewCell

@property (nonatomic, copy) NSString *sourceValue;
@property (nonatomic, copy) NSString *convertedValue;

@property (nonatomic, weak) UIView *adView;

@end
