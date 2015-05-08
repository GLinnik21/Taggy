//
//  TGFavouriteCurrenciesViewController.h
//  Taggy
//
//  Created by Gleb Linkin on 06/05/15.
//  Copyright (c) 2015 Gleb Linkin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TGFavouriteCurrenciesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
