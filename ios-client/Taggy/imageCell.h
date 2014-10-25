//
//  imageCell.h
//  Test
//
//  Created by Gleb Linkin on 10/10/14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface imageCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UIImageView *cellImageView;
@property (weak, nonatomic) IBOutlet UILabel *cellAtransfLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellBtransfLabel;

@end
