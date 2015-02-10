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
@property (nonatomic, assign) bool *checkSell;
@property (nonatomic, retain) UIPickerView *buyPickerView;
@property (nonatomic, assign) bool *checkBuy;

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
    self.buyTextField.inputAccessoryView = toolBar;
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
        self.checkSell = false;
        self.checkBuy = false;
        [self.buyPickerView removeFromSuperview];
    }
    [self.sellTextField resignFirstResponder];
    [self.buyTextField resignFirstResponder];
}

- (IBAction)buyAction:(id)sender {
    if (self.checkBuy == false) {
        [self.buyButton setTitle:@"Changing..." forState:UIControlStateNormal];
        self.buyPickerView = [[UIPickerView alloc] init];
        [self.buyPickerView setDelegate:self];
        self.buyPickerView.showsSelectionIndicator = YES;
        UIToolbar *toolBar= [[UIToolbar alloc] init];
        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        
        UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(changeSellCurrency:)];
        
        [toolBar setItems:@[flexSpace, barButtonDone] animated:YES];
        [toolBar sizeToFit];
        
        [self.view insertSubview:self.buyPickerView atIndex:0];
        [self.buyPickerView insertSubview:toolBar atIndex:10];
        [self.buyPickerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.view);
            make.height.equalTo(self.view).multipliedBy(0.45);
            make.bottom.equalTo(self.view);
        }];
        [toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.buyPickerView);
            make.top.equalTo(self.buyPickerView);
            
        }];
        self.checkSell = false;
        self.checkBuy = false;
        [self.sellPickerView removeFromSuperview];
    }
    [self.sellTextField resignFirstResponder];
    [self.buyTextField resignFirstResponder];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    if (pickerView = self.sellPickerView) {
        [self.sellButton setTitle:[self.dataSource objectAtIndex:row] forState:UIControlStateNormal];
    }else if (pickerView = self.buyPickerView){
        [self.buyButton setTitle:[self.dataSource objectAtIndex:row] forState:UIControlStateNormal];
    }
    
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.dataSource.count;
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.dataSource objectAtIndex:row];
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
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
    self.checkBuy = false;
    NSLog(@"Done");
}
- (IBAction)sellEditingDidBegin:(id)sender {
    [self.sellPickerView removeFromSuperview];
    [self.buyPickerView removeFromSuperview];
    self.checkSell = false;
    self.checkBuy = false;
}
- (IBAction)buyEditingDidBegin:(id)sender {
    [self.sellPickerView removeFromSuperview];
    [self.buyPickerView removeFromSuperview];
    self.checkSell = false;
    self.checkBuy = false;
}
- (void)sellTextFieldEndEditing: (id)sender {
    [self.sellTextField resignFirstResponder];
    [self.buyTextField resignFirstResponder];
}

@end
