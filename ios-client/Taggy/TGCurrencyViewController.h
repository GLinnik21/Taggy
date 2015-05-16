//
//  TGCurrencyViewController.h
//  Taggy
//
//  Created by Gleb Linkin on 13/03/15.
//  Copyright (c) 2015 Gleb Linkin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TGCurrencyViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy) NSString *settingsKey;
@property (nonatomic, assign) BOOL fav;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
