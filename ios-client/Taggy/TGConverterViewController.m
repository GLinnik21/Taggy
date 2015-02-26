//
//  TGConverterViewController.m
//  Taggy
//
//  Created by Gleb Linkin on 05/02/15.
//  Copyright (c) 2015 Gleb Linkin. All rights reserved.
//

#import "TGConverterViewController.h"
#import <Masonry/Masonry.h>
#import <QuartzCore/QuartzCore.h>

#import "TGCurrency.h"

@interface TGConverterViewController (){
    int previousStepperValue;
    int totalNumber;
}

@property (strong, nonatomic) NSArray *dataSource;
@property (nonatomic, retain) UIPickerView *sellPickerView;
@property (nonatomic, assign) BOOL checkSell;
@property (nonatomic, retain) UIPickerView *buyPickerView;
@property (nonatomic, assign) BOOL checkBuy;

@end

@implementation TGConverterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self.sellButton setTitle:[defaults objectForKey:@"country"] forState:UIControlStateNormal];
    [self.buyButton setTitle:[defaults objectForKey:@"transf"] forState:UIControlStateNormal];

    self.dataSource = @[
        @"AUD",
        @"BYR",
        @"EUR",
        @"GBP",
        @"RUB",
        @"USD"
    ];

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
    
    
    //Graph
    UIView* graphBG= [[UIView alloc] init];
    
    graphBG.layer.cornerRadius = 7;
    graphBG.layer.masksToBounds = YES;
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:(247/255.0) green:(149/255.0) blue:(85/255.0) alpha:1] CGColor], (id)[[UIColor colorWithRed:(255/255.0) green:(51/255.0) blue:(51/255.0) alpha:1] CGColor], nil];
    [graphBG.layer insertSublayer:gradient atIndex:0];
    graphBG.backgroundColor = [UIColor redColor];
    [self.view insertSubview:graphBG belowSubview:self.graphView];
    [graphBG mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.graphView);
        make.height.equalTo(self.graphView);
        make.center.equalTo(self.graphView);
    }];
    
    self.arrayOfValues = [[NSMutableArray alloc] init];
    self.arrayOfDates = [[NSMutableArray alloc] init];
    
    totalNumber = 0;
    
    for (int i = 0; i < 10; i++) {
        [self.arrayOfValues addObject:@([self getRandomInteger])]; // Random values for the graph
        [self.arrayOfDates addObject:[NSString stringWithFormat:@"%@", @(2000 + i)]]; // Dates for the X-Axis of the graph
        
        totalNumber = totalNumber + [[self.arrayOfValues objectAtIndex:i] intValue]; // All of the values added together
    }
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = {
        1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0, 0.0
    };
    
    self.graphView.gradientBottom = CGGradientCreateWithColorComponents(colorspace, components, locations, num_locations);
    self.graphView.colorTop = [UIColor clearColor];
    self.graphView.colorBottom = [UIColor clearColor];
    self.graphView.colorLine = [UIColor whiteColor];
    self.graphView.colorXaxisLabel = [UIColor whiteColor];
    self.graphView.colorYaxisLabel = [UIColor whiteColor];
    self.graphView.widthLine = 3.0;
    self.graphView.enableTouchReport = YES;
    self.graphView.enablePopUpReport = YES;
    self.graphView.enableBezierCurve = YES;
    self.graphView.enableYAxisLabel = YES;
    self.graphView.autoScaleYAxis = YES;
    self.graphView.alwaysDisplayDots = NO;
    self.graphView.enableReferenceXAxisLines = YES;
    self.graphView.enableReferenceYAxisLines = YES;
    self.graphView.enableReferenceAxisFrame = YES;
    self.graphView.animationGraphStyle = BEMLineAnimationDraw;
    self.graphView.colorTouchInputLine = [UIColor colorWithWhite:1 alpha:1];
    self.graphView.widthTouchInputLine = 2.0f;
    self.graphView.colorBackgroundYaxis =[UIColor clearColor];
}

- (NSString *)lineGraph:(BEMSimpleLineGraphView *)graph labelOnXAxisForIndex:(NSInteger)index {
    NSString *label = [self.arrayOfDates objectAtIndex:index];
    return [label stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
}

- (NSInteger)getRandomInteger
{
    NSInteger i1 = (int)(arc4random() % 10000);
    return i1;
}

- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    return (int)[self.arrayOfValues count];
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index {
    return [[self.arrayOfValues objectAtIndex:index] floatValue];
}

- (NSInteger)numberOfGapsBetweenLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph {
    return 1;
}

- (IBAction)sellAction:(id)sender {
    if (self.checkSell == NO) {
        [self.sellButton setTitle:@"AUD" forState:UIControlStateNormal];
        UIView *pickerViewRoot = [[UIView alloc] init];
        pickerViewRoot.backgroundColor = [UIColor whiteColor];
        
        self.sellPickerView = [[UIPickerView alloc] init];
        self.sellPickerView.delegate = self;
        self.sellPickerView.showsSelectionIndicator = YES;
        UIToolbar *toolBar = [[UIToolbar alloc] init];
        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        
        UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(changeSellCurrency:)];
        
        [toolBar setItems:@[flexSpace, barButtonDone] animated:YES];
        
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
            make.top.equalTo(pickerViewRoot);
            make.height.equalTo(pickerViewRoot).multipliedBy(0.15f);
        }];
        [self.sellPickerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(pickerViewRoot);
            make.top.equalTo(toolBar.mas_bottom);
            make.bottom.equalTo(pickerViewRoot);
            make.center.equalTo(pickerViewRoot);
        }];
        self.checkBuy = NO;
        self.checkSell = YES;
        [self.buyPickerView.superview removeFromSuperview];
    }
    [self.sellTextField resignFirstResponder];
    [self.buyTextField resignFirstResponder];
}


- (IBAction)buyAction:(id)sender {
    if (self.checkBuy == NO) {
        [self.buyButton setTitle:@"AUD" forState:UIControlStateNormal];
        UIView *pickerViewRoot = [[UIView alloc] init];
        pickerViewRoot.backgroundColor = [UIColor whiteColor];

        self.buyPickerView = [[UIPickerView alloc] init];
        self.buyPickerView.delegate = self;
        self.buyPickerView.showsSelectionIndicator = YES;

        UIToolbar *toolBar = [[UIToolbar alloc] init];
        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];

        UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(changeBuyCurrency:)];

        [toolBar setItems:@[flexSpace, barButtonDone] animated:YES];

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
            make.top.equalTo(pickerViewRoot);
            make.height.equalTo(pickerViewRoot).multipliedBy(0.15f);
        }];
        [self.buyPickerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(pickerViewRoot);
            make.top.equalTo(toolBar.mas_bottom);
            make.bottom.equalTo(pickerViewRoot);
            make.center.equalTo(pickerViewRoot);
        }];
        self.checkBuy = YES;
        self.checkSell = NO;
        [self.sellPickerView.superview removeFromSuperview];
    }
    [self.sellTextField resignFirstResponder];
    [self.buyTextField resignFirstResponder];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    if (pickerView == self.sellPickerView) {
        [self.sellButton setTitle:[self.dataSource objectAtIndex:row] forState:UIControlStateNormal];
    }
    else if (pickerView == self.buyPickerView) {
        [self.buyButton setTitle:[self.dataSource objectAtIndex:row] forState:UIControlStateNormal];
    }
    [self valueChanged];
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

- (void)changeSellCurrency:(id)sender
{
    [UIView animateWithDuration:0.3 animations:^{
        CGAffineTransform transfrom = CGAffineTransformMakeTranslation(0, 200);
        self.sellPickerView.superview.transform = transfrom;
        self.sellPickerView.superview.alpha = 1.0f - self.sellPickerView.alpha;
    }];
    self.checkSell = NO;
    self.checkBuy = NO;
    NSLog(@"Done");
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
    NSLog(@"Done");
}

- (IBAction)sellEditingDidBegin:(id)sender {
    [self.sellPickerView.superview removeFromSuperview];
    [self.buyPickerView.superview removeFromSuperview];
    self.checkSell = NO;
    self.checkBuy = NO;
}

- (void)valueChanged {
    TGCurrency *fromCurency = [TGCurrency currencyForCode:self.sellButton.currentTitle];
    TGCurrency *toCurency = [TGCurrency currencyForCode:self.buyButton.currentTitle];
    
    NSString *digits = [self.sellTextField.text stringByReplacingOccurrencesOfString:@"," withString:@"."];
    
    CGFloat value = (CGFloat)[digits floatValue];
    CGFloat rate = 1.0f;
    
    if (fromCurency != nil) {
        rate *= fromCurency.value;
    }
    if (toCurency != nil) {
        rate /= toCurency.value;
    }
    
    CGFloat result = value * rate;

    if ([self.buyButton.currentTitle  isEqual:@"BYR"]) {
        if (result == 0.0f) {
            self.buyTextField.text = nil;
        }else{
            self.buyTextField.text = [NSString stringWithFormat: @"%.0f", result];
        }
    }else{
        if (result == 0.0f) {
            self.buyTextField.text = nil;
        }else{
            self.buyTextField.text = [NSString stringWithFormat: @"%.2f", result];
        }
    }
}

- (IBAction)swapCurrencies:(id)sender {
    NSString *sell;
    NSString *buy;
    sell = self.sellButton.currentTitle;
    buy = self.buyButton.currentTitle;
    [self.sellButton setTitle:buy forState:UIControlStateNormal];
    [self.buyButton setTitle:sell forState:UIControlStateNormal];
    [self valueChanged];
}

- (IBAction)sellEditingChanged:(id)sender {
    [self valueChanged];
}

- (void)sellTextFieldEndEditing: (id)sender {
    [self.sellTextField resignFirstResponder];
}

@end
