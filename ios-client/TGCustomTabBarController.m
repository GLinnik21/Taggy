//
//  TGCustomTabBarController.m
//  Taggy
//
//  Created by Gleb Linkin on 10/23/14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import "TGCustomTabBarController.h"

@implementation TGCustomTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UITabBar appearance] setTintColor:[UIColor orangeColor]];
    
    self.selectedIndex = 1;
}

@end
