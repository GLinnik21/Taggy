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
    // Do any additional setup after loading the view.
    
    NSArray *data = [[NSArray alloc] initWithObjects:@"USD", @"BYR", @"RUB", @"EUR", @"AUD", nil];
    
    self.arrayTransf = data;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark Picker Delegate Methods

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    // This method provides the data for a specific row in a specific component.
    
    return [_arrayTransf objectAtIndex:row];
    
}

#pragma mark Picker Data Source Methods

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    // This method returns the number of components we want in our Picker.
    // The components are the colums.
    
    return 1;
    
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    // This returns the number of rows in each component. We use the count of our array to determine the number of rows.
    
    return [_arrayTransf count];
}

- (void)viewWillDisappear:(BOOL)animated;
{
    NSString *select = [_arrayTransf objectAtIndex:[_transferenceCurrencyPicker selectedRowInComponent:0]];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:select forKey:@"transf"];
    NSLog(@"Set to userDefaults in transf: %@", [userDefaults objectForKey:@"transf"]);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
