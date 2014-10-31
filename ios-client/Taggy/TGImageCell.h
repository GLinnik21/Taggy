//
//  TGImageCell.h
//  Taggy
//
//  Created by Gleb Linkin on 10/10/14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TGImageCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *cellImageView;
@property (nonatomic, weak) IBOutlet UILabel *cellSourcePriceLabel;
@property (nonatomic, weak) IBOutlet UILabel *cellConvertedPriceLabel;

@end
