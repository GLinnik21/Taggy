//
//  TGCurrencySettingsController.m
//  
//
//  Created by Gleb Linkin on 29/11/14.
//
//

#import "TGCurrencySettingsController.h"

@interface TGCurrencySettingsController ()

@end

@implementation TGCurrencySettingsController

-(void)viewWillAppear:(BOOL)animated{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    self.countryCurrencyDetail.text = [userDefaults objectForKey:@"country"];
    self.transferenceCurrencyDetail.text = [userDefaults objectForKey:@"transf"];
    
    [self.tableView reloadData];
}

@end
