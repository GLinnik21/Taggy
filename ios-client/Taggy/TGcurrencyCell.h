//
//  TGcurrencyCell.h
//  Taggy
//
//  Created by Gleb Linkin on 18/04/15.
//  Copyright (c) 2015 Gleb Linkin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TGcurrencyCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *ISOLabel;
@property (weak, nonatomic) IBOutlet UILabel *FullLabel;
@property (weak, nonatomic) IBOutlet UILabel *RateLabel;

@end
