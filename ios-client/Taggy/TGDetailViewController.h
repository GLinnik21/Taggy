//
//  TGDetailViewController.h
//  Test
//
//  Created by Gleb Linkin on 10/11/14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Data.h"

@interface TGDetailViewController : UIViewController

@property (nonatomic, strong) Data *detail;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *BTransfDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *ATransfDetailLabel;

@end
