//
//  TGEditViewController.m
//  Taggy
//
//  Created by Gleb Linkin on 05/06/15.
//  Copyright (c) 2015 Gleb Linkin. All rights reserved.
//

#import "TGEditViewController.h"
#import "TGCurrency.h"
#import <Masonry/Masonry.h>
#import <QuartzCore/QuartzCore.h>
#import "SVProgressHUD.h"

@interface TGEditViewController ()

@property (strong, nonatomic) NSArray *dataSource;
@property (nonatomic, retain) UIPickerView *sellPickerView;
@property (nonatomic, assign) BOOL checkSell;
@property (nonatomic, retain) UIPickerView *buyPickerView;
@property (nonatomic, assign) BOOL checkBuy;

@end

@implementation TGEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.sellButton setTitle:[[NSUserDefaults standardUserDefaults] objectForKey:@"sell_key"] forState:UIControlStateNormal];
    [self.buyButton setTitle:[[NSUserDefaults standardUserDefaults] objectForKey:@"buy_key"]  forState:UIControlStateNormal];
    
    UIToolbar *toolBar = [[UIToolbar alloc] init];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                               target:self
                                                                               action:nil];
    
    UIBarButtonItem *barButtonDone =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self
                                                  action:@selector(sellTextFieldEndEditing:)];
    [barButtonDone setTintColor:[UIColor orangeColor]];
    [toolBar sizeToFit];
    
    [toolBar setItems:@[ flexSpace, barButtonDone ] animated:YES];
    self.sellTextField.inputAccessoryView = toolBar;
    self.sellTextField.keyboardType = UIKeyboardTypeDecimalPad;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    self.dataSource = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"fav_currencies"]];
    self.sellTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"conv_value"];
    [self valueChanged];
    [self.buyPickerView.superview removeFromSuperview];
    [self.sellPickerView.superview removeFromSuperview];
}

- (IBAction)sellAction:(id)sender
{
    if ([self.dataSource count] != 0) {
        if (self.checkSell == NO) {
            UIView *pickerViewRoot = [[UIView alloc] init];
            pickerViewRoot.backgroundColor = [UIColor whiteColor];
            
            self.sellPickerView = [[UIPickerView alloc] init];
            self.sellPickerView.delegate = self;
            self.sellPickerView.showsSelectionIndicator = YES;
            UIToolbar *toolBar = [[UIToolbar alloc] init];
            UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
            
            UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(changeSellCurrency:)];
            
            [toolBar setItems:@[ flexSpace, barButtonDone ] animated:YES];
            
            [self.view addSubview:pickerViewRoot];
            [pickerViewRoot addSubview:self.sellPickerView];
            [pickerViewRoot addSubview:toolBar];
            
            [pickerViewRoot mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(self.view);
                make.height.equalTo(self.view).multipliedBy(0.45f);
                make.bottom.equalTo(self.view);
            }];
            
            [toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(pickerViewRoot);
                make.top.equalTo(pickerViewRoot.mas_top);
            }];
            [self.sellPickerView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(pickerViewRoot);
                make.top.equalTo(toolBar);
                make.bottom.equalTo(pickerViewRoot);
                make.center.equalTo(pickerViewRoot);
            }];
            
            self.checkBuy = NO;
            self.checkSell = YES;
            [self.buyPickerView.superview removeFromSuperview];
            
            if ([self.dataSource containsObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"sell_key"]]) {
                [self.sellPickerView selectRow:[self.dataSource indexOfObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"sell_key"]] inComponent:0 animated:YES];
            }else{
                [self.sellButton setTitle:[self.dataSource objectAtIndex:0] forState:UIControlStateNormal];
            }
        }
        
        [self.sellTextField resignFirstResponder];
        [self.buyTextField resignFirstResponder];
    }else{
        [SVProgressHUD setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.9]];
        [SVProgressHUD setForegroundColor:[UIColor orangeColor]];
        [SVProgressHUD setInfoImage:[UIImage imageNamed:@"fav"]];
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"no_fav_info", nil)];
    }
}

- (IBAction)buyAction:(id)sender
{
    if ([self.dataSource count] != 0) {
        if (self.checkBuy == NO) {
            UIView *pickerViewRoot = [[UIView alloc] init];
            pickerViewRoot.backgroundColor = [UIColor whiteColor];
            
            self.buyPickerView = [[UIPickerView alloc] init];
            self.buyPickerView.delegate = self;
            self.buyPickerView.showsSelectionIndicator = YES;
            
            UIToolbar *toolBar = [[UIToolbar alloc] init];
            UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
            
            UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(changeBuyCurrency:)];
            
            [toolBar setItems:@[ flexSpace, barButtonDone ] animated:YES];
            
            [self.view addSubview:pickerViewRoot];
            [pickerViewRoot addSubview:self.buyPickerView];
            [pickerViewRoot addSubview:toolBar];
            
            [pickerViewRoot mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(self.view);
                make.height.equalTo(self.view).multipliedBy(0.45f);
                make.bottom.equalTo(self.view);
            }];
            [toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(pickerViewRoot);
                make.top.equalTo(pickerViewRoot.mas_top);
            }];
            [self.buyPickerView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(pickerViewRoot);
                make.top.equalTo(toolBar);
                make.bottom.equalTo(pickerViewRoot);
                make.center.equalTo(pickerViewRoot);
            }];
            self.checkBuy = YES;
            self.checkSell = NO;
            [self.sellPickerView.superview removeFromSuperview];
            
            if ([self.dataSource containsObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"buy_key"]]) {
                [self.buyPickerView selectRow:[self.dataSource indexOfObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"buy_key"]] inComponent:0 animated:YES];
            }else{
                [self.buyButton setTitle:[self.dataSource objectAtIndex:0] forState:UIControlStateNormal];
            }
        }
        [self.sellTextField resignFirstResponder];
        [self.buyTextField resignFirstResponder];
    }else{
        [SVProgressHUD setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.9]];
        [SVProgressHUD setForegroundColor:[UIColor orangeColor]];
        [SVProgressHUD setInfoImage:[UIImage imageNamed:@"fav"]];
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"no_fav_info", nil)];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == self.sellPickerView) {
        [self.sellButton setTitle:[self.dataSource objectAtIndex:row] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults] setObject:[self.dataSource objectAtIndex:row] forKey:@"sell_key"];
    }
    else if (pickerView == self.buyPickerView) {
        [self.buyButton setTitle:[self.dataSource objectAtIndex:row] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults] setObject:[self.dataSource objectAtIndex:row] forKey:@"buy_key"];
    }

    [self valueChanged];
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.dataSource.count;
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.dataSource objectAtIndex:row];
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    int sectionWidth = 300;
    
    return sectionWidth;
}

- (void)changeSellCurrency:(id)sender
{
    [UIView animateWithDuration:0.3 animations:^{
        CGAffineTransform transfrom = CGAffineTransformMakeTranslation(0, 200);
        self.sellPickerView.superview.transform = transfrom;
        self.sellPickerView.superview.alpha = 1.0f - self.sellPickerView.alpha;
    }];
    self.checkSell = NO;
    self.checkBuy = NO;
    DDLogInfo(@"Sell: Done");
}

- (void)changeBuyCurrency:(id)sender
{
    [UIView animateWithDuration:0.3 animations:^{
        CGAffineTransform transfrom = CGAffineTransformMakeTranslation(0, 200);
        self.buyPickerView.superview.transform = transfrom;
        self.buyPickerView.superview.alpha = 1.0f - self.buyPickerView.alpha;
    }];
    self.checkSell = NO;
    self.checkBuy = NO;
    DDLogInfo(@"Buy: Done");
}

- (IBAction)sellEditingDidBegin:(id)sender
{
    [self.sellPickerView.superview removeFromSuperview];
    [self.buyPickerView.superview removeFromSuperview];
    self.checkSell = NO;
    self.checkBuy = NO;
}

- (void)valueChanged
{
    TGCurrency *fromCurency = [TGCurrency currencyForCode:self.sellButton.currentTitle];
    TGCurrency *toCurency = [TGCurrency currencyForCode:self.buyButton.currentTitle];
    
    NSString *digits = [self.sellTextField.text stringByReplacingOccurrencesOfString:@"," withString:@"."];
    [[NSUserDefaults standardUserDefaults] setObject:digits forKey:@"conv_value"];
    
    CGFloat value = (CGFloat)[digits floatValue];
    CGFloat rate = 1.0f;
    
    if (fromCurency != nil) {
        rate /= fromCurency.value;
    }
    if (toCurency != nil) {
        rate *= toCurency.value;
    }
    
    CGFloat result = value * rate;
    
    if (result == 0.0f) {
        self.buyTextField.text = nil;
    }
    else {
        if ([self.buyButton.currentTitle isEqual:@"BYR"]) {
            self.buyTextField.text = [NSString stringWithFormat:@"%.0f", result];
        }
        else {
            self.buyTextField.text = [NSString stringWithFormat:@"%.2f", result];
        }
    }
}

- (IBAction)swapCurrencies:(id)sender
{
    NSString *sell = self.sellButton.currentTitle;;
    NSString *buy = self.buyButton.currentTitle;
    [[NSUserDefaults standardUserDefaults] setObject:sell forKey:@"buy_key"];
    [[NSUserDefaults standardUserDefaults] setObject:buy forKey:@"sell_key"];
    [self.sellButton setTitle:buy forState:UIControlStateNormal];
    [self.buyButton setTitle:sell forState:UIControlStateNormal];
    [self valueChanged];
}

- (IBAction)sellEditingChanged:(id)sender
{
    [self valueChanged];
}

- (void)sellTextFieldEndEditing:(id)sender
{
    [self.sellTextField resignFirstResponder];
}

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
