//
//  DetailViewController.m
//  Test
//
//  Created by Gleb Linkin on 10/11/14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import "DetailViewController.h"
#import "Data.h"
#import "ViewController.h"

@implementation DetailViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self reloadData];
}

- (void)setDetail:(Data *)detail
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
