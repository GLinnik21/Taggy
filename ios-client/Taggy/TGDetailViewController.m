//
//  TGDetailViewController.m
//  Test
//
//  Created by Gleb Linkin on 10/11/14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import "TGDetailViewController.h"
#import "TGData.h"
#import "TGViewController.h"

@implementation TGDetailViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self reloadData];
}

- (void)setDetail:(TGData *)detail
{
    _detail=detail;
}

- (void)reloadData
{
    if (!_detail) {
        return;
    }
    self.navigationItem.title = _detail.Btransf;
    
    self.BTransfDetailLabel.text = _detail.Btransf;
    self.ATransfDetailLabel.text = _detail.Atransf;
    self.imageView.image = _detail.image;
    
    
    _scrollView.contentSize = _scrollView.frame.size;
}

@end
