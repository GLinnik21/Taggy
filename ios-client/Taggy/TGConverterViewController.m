//
//  TGConverterViewController.m
//  Taggy
//
//  Created by Gleb Linkin on 05/02/15.
//  Copyright (c) 2015 Gleb Linkin. All rights reserved.
//

#import "TGConverterViewController.h"
#import <Masonry/Masonry.h>

@interface TGConverterViewController ()

@property (strong, nonatomic) NSArray *dataSource;
@property (nonatomic, retain) UIPickerView *sellPickerView;
@property (nonatomic, assign) BOOL *checkSell;

@end

@implementation TGConverterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = [NSArray arrayWithObjects:
                       @"USD",
                       @"BYR",
                       @"RUB",
                       @"EUR",
                       @"AUD", nil];
    UIToolbar *toolBar= [[UIToolbar alloc] init];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(sellTextFieldEndEditing:)];
    [barButtonDone setTintColor:[UIColor orangeColor]];
    [toolBar sizeToFit];
    
    [toolBar setItems:@[flexSpace, barButtonDone] animated:YES];
    self.sellTextField.inputAccessoryView = toolBar;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sellAction:(id)sender {
    if (self.checkSell == false) {
        [self.sellButton setTitle:@"Changing..." forState:UIControlStateNormal];
        self.sellPickerView = [[UIPickerView alloc] init];
        [self.sellPickerView setDelegate:self];
        self.sellPickerView.showsSelectionIndicator = YES;
        UIToolbar *toolBar= [[UIToolbar alloc] init];
        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        
        UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(changeSellCurrency:)];
        
        [toolBar setItems:@[flexSpace, barButtonDone] animated:YES];
        [toolBar sizeToFit];
        
        [self.view insertSubview:self.sellPickerView atIndex:0];
        [self.sellPickerView insertSubview:toolBar atIndex:10];
        [self.sellPickerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.view);
            make.height.equalTo(self.view).multipliedBy(0.45);
            make.bottom.equalTo(self.view);
        }];
        [toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.sellPickerView);
            make.top.equalTo(self.sellPickerView);
            
        }];
        self.checkSell = true;
    }
    [self.sellTextField endEditing:YES];
}

- (IBAction)buyAction:(id)sender {
}

- (void)pickerView:(UIPickerView *)sellPickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    // Handle the selection
    [self.sellButton setTitle:[self.dataSource objectAtIndex:row] forState:UIControlStateNormal];
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)sellPickerView numberOfRowsInComponent:(NSInteger)component {
    return self.dataSource.count;
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)sellPickerView {
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)sellPickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.dataSource objectAtIndex:row];
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)sellPickerView widthForComponent:(NSInteger)component {
    int sectionWidth = 300;
    
    return sectionWidth;
}

-(void)changeSellCurrency:(id)sender
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.6];
    CGAffineTransform transfrom = CGAffineTransformMakeTranslation(0, 200);
    self.sellPickerView.transform = transfrom;
    self.sellPickerView.alpha = self.sellPickerView.alpha * (-1) + 1;
    [UIView commitAnimations];
    self.checkSell = false;
    NSLog(@"Done");
}
- (IBAction)sellEdititngDidBegin:(id)sender {
    [self.sellPickerView removeFromSuperview];
    self.checkSell = false;
    [self.sellTextField setDelegate:self];
    [self.sellTextField setReturnKeyType:UIReturnKeyDone];
    [self.sellTextField addTarget:self action:@selector(sellTextFieldEndEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
}

- (void)sellTextFieldEndEditing: (id)sender {
    [self.sellTextField resignFirstResponder];
}

@end
