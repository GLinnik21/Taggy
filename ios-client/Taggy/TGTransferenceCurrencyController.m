//
//  TGTransferenceCurrencyController.m
//  Taggy
//
//  Created by Gleb Linkin on 29/11/14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import "TGTransferenceCurrencyController.h"

@interface TGTransferenceCurrencyController ()

@property (strong, nonatomic) NSArray *arrayTransf;

@end

@implementation TGTransferenceCurrencyController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *data = [[NSArray alloc] initWithObjects:@"USD", @"BYR", @"RUB", @"EUR", @"AUD", nil];
    self.arrayTransf = data;
}

#pragma mark Picker Delegate Methods

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return self.arrayTransf[row];
    
}

#pragma mark Picker Data Source Methods

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {

    return 1;
    
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return self.arrayTransf.count;
}

- (void)viewWillDisappear:(BOOL)animated;
{
    NSString *select = [_arrayTransf objectAtIndex:[_transferenceCurrencyPicker selectedRowInComponent:0]];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:select forKey:@"transf"];
    NSLog(@"Set to userDefaults in transf: %@", [userDefaults objectForKey:@"transf"]);
}

@end
