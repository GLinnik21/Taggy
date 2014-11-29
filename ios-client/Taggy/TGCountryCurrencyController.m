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
    // Do any additional setup after loading the view.
    
    NSArray *data = [[NSArray alloc] initWithObjects:@"USD", @"BYR", @"RUB", @"EUR", @"AUD", nil];
    self.arrayCountry = data;

    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Picker Delegate Methods

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    // This method provides the data for a specific row in a specific component.
    
    return [_arrayCountry objectAtIndex:row];
    
}

#pragma mark Picker Data Source Methods

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    // This method returns the number of components we want in our Picker.
    // The components are the colums.
    
    return 1;
    
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    // This returns the number of rows in each component. We use the count of our array to determine the number of rows.
    
    return [_arrayCountry count];
}

- (void)viewWillDisappear:(BOOL)animated;
{
    NSString *select = [_arrayCountry objectAtIndex:[_countryCurrencyPicker selectedRowInComponent:0]];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:select forKey:@"country"];
    NSLog(@"Set to userDefaults in country: %@", [userDefaults objectForKey:@"country"]);
}

/*NSString *select = [_arrayCountry objectAtIndex:[_countryCurrencyPicker selectedRowInComponent:0]];
NSLog(@"%@", select);*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
