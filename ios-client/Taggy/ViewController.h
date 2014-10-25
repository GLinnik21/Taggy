//
//  ViewController.h
//  Test
//
//  Created by Gleb Linkin on 9/29/14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate>
{
    UIImage *image;
    NSArray *_data;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end