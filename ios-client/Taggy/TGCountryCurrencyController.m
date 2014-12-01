//
//  TGCountryCurrencyController.m
//  Taggy
//
//  Created by Gleb Linkin on 29/11/14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import "TGCountryCurrencyController.h"

@interface TGCountryCurrencyController ()

@property (strong, nonatomic) NSArray *arrayCountry;

@end

@implementation TGCountryCurrencyController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *data = [[NSArray alloc] initWithObjects:@"USD", @"BYR", @"RUB", @"EUR", @"AUD", nil];
    self.arrayCountry = data;
}

#pragma mark Picker Delegate Methods

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return self.arrayCountry[row];
    
}

#pragma mark Picker Data Source Methods

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
    
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return self.arrayCountry.count;
}

- (void)viewWillDisappear:(BOOL)animated;
{
    NSString *select = [_arrayCountry objectAtIndex:[_countryCurrencyPicker selectedRowInComponent:0]];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:select forKey:@"country"];
    NSLog(@"Set to userDefaults in country: %@", [userDefaults objectForKey:@"country"]);
}

@end
