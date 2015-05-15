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
#import "SVProgressHUD.h"

#import "TGCurrency.h"
#import "TGSettingsManager.h"
#import <ARAnalytics/ARAnalytics.h>

static NSTimeInterval const kTGOneDay = 1 * 24 * 3600;

@interface TGConverterViewController ()

@property (strong, nonatomic) NSArray *dataSource;
@property (nonatomic, retain) UIPickerView *sellPickerView;
@property (nonatomic, assign) BOOL checkSell;
@property (nonatomic, retain) UIPickerView *buyPickerView;
@property (nonatomic, assign) BOOL checkBuy;

@property (nonatomic, weak) IBOutlet UISegmentedControl *intervalControl;

@end

@implementation TGConverterViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.dataSource = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"fav_currencies"]];
    
    [ARAnalytics pageView:@"Converter"];
}

- (void)viewDidLoad
{
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

    //Graph
    UIView *graphBG = [[UIView alloc] init];

    graphBG.layer.cornerRadius = 5;
    graphBG.layer.masksToBounds = YES;

    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:(247 / 255.0)green:(149 / 255.0)blue:(85 / 255.0)alpha:1] CGColor], (id)[[UIColor colorWithRed:(255 / 255.0)green:(51 / 255.0)blue:(51 / 255.0)alpha:1] CGColor], nil];
    [graphBG.layer insertSublayer:gradient atIndex:0];
    [self.view insertSubview:graphBG belowSubview:self.graphView];
    [graphBG mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.graphView);
        make.height.equalTo(self.graphView);
        make.center.equalTo(self.graphView);
    }];

    [self formatGraphData];

    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    size_t num_locations = 2;
    CGFloat locations[2] = {0.0, 1.0};
    CGFloat components[8] = {
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0};

    CGGradientRef gradientRef = CGGradientCreateWithColorComponents(colorspace, components, locations, num_locations);
    CGColorSpaceRelease(colorspace);
    self.graphView.gradientBottom = gradientRef;
    self.graphView.colorTop = [UIColor clearColor];
    self.graphView.colorBottom = [UIColor clearColor];
    self.graphView.colorLine = [UIColor whiteColor];
    self.graphView.colorXaxisLabel = [UIColor whiteColor];
    self.graphView.colorYaxisLabel = [UIColor whiteColor];
    self.graphView.widthLine = 3.0;
    self.graphView.enableTouchReport = YES;
    self.graphView.enablePopUpReport = YES;
    self.graphView.enableBezierCurve = NO;
    self.graphView.enableYAxisLabel = YES;
    self.graphView.autoScaleYAxis = YES;
    self.graphView.alwaysDisplayDots = YES;
    self.graphView.sizePoint = 6.5;
    self.graphView.enableReferenceXAxisLines = YES;
    self.graphView.enableReferenceYAxisLines = YES;
    self.graphView.enableReferenceAxisFrame = YES;
    self.graphView.animationGraphStyle = BEMLineAnimationDraw;
    self.graphView.colorTouchInputLine = [UIColor colorWithWhite:1 alpha:1];
    self.graphView.widthTouchInputLine = 3.0f;
    self.graphView.colorBackgroundYaxis = [UIColor clearColor];
    
}

- (void)formatGraphData
{
    self.arrayOfValues = [[NSMutableArray alloc] init];
    self.arrayOfDates = [[NSMutableArray alloc] init];

    NSTimeInterval interval = kTGOneDay;
    NSUInteger skipHours = 2;
    NSInteger intervalIndex = self.intervalControl.selectedSegmentIndex;
    switch (intervalIndex) {
        case 0: // 1d
            interval = kTGOneDay;
            skipHours = 1;
            break;

        case 1: // 1w
            interval = 7 * kTGOneDay;
            skipHours = 10;
            break;

        case 2: // 2w
            interval = 14 * kTGOneDay;
            skipHours = 10;
            break;

        case 3: // 1m
            interval = 30 * kTGOneDay;
            skipHours = 15;
            break;
    }

    TGCurrency *sourceCurrency = [TGCurrency currencyForCode:self.sellButton.currentTitle];
    TGCurrency *targetCurrency = [TGCurrency currencyForCode:self.buyButton.currentTitle];

    RLMResults *items = [[sourceCurrency.historyItems objectsWhere:@"date >= %@", [NSDate dateWithTimeIntervalSinceNow:-interval]]
        sortedResultsUsingProperty:@"date"
                         ascending:YES];
    NSInteger skipCount = skipHours;
    CGFloat averageValue = 0;
    NSTimeInterval averegeTime = 0;
    for (TGCurrencyHistoryItem *item in items) {
        TGCurrencyHistoryItem *targetItem = [targetCurrency.historyItems objectsWhere:@"date == %@", item.date].firstObject;
        if (targetItem == nil)
            continue;

        CGFloat value = targetItem.value / item.value;
        NSDate *date = item.date;

        if (skipCount-- > 0) {
            averageValue += value;
            averegeTime += date.timeIntervalSinceNow;
            continue;
        }
        else {
            skipCount = skipHours;
            value = averageValue / skipHours;
            date = [NSDate dateWithTimeIntervalSinceNow:averegeTime / skipHours];
            averegeTime = 0;
            averageValue = 0;
        }

        NSString *dateString = [NSDateFormatter localizedStringFromDate:date
                                                              dateStyle:NSDateFormatterShortStyle
                                                              timeStyle:NSDateFormatterShortStyle];
        
        [self.arrayOfValues addObject:@(value)];
        [self.arrayOfDates addObject:dateString];
    }
}
- (NSString *)popUpSuffixForlineGraph:(BEMSimpleLineGraphView *)graph{
    NSString *suffix = [NSString stringWithFormat:@" %@", self.buyButton.currentTitle];
    return suffix;
}

- (NSString *)lineGraph:(BEMSimpleLineGraphView *)graph labelOnXAxisForIndex:(NSInteger)index
{
    NSString *label = [self.arrayOfDates objectAtIndex:index];
    return [label stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
}

- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph
{
    return (int)[self.arrayOfValues count];
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index
{
    return [[self.arrayOfValues objectAtIndex:index] floatValue];
}

- (NSInteger)numberOfGapsBetweenLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph
{
    return 1;
}

- (NSString *)noDataLabelTextForLineGraph:(BEMSimpleLineGraphView *)graph
{
    return NSLocalizedString(@"NoData", nil);
}

- (IBAction)intervalValueChanged:(id)sender
{
    [self formatGraphData];
    [self.graphView reloadGraph];
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
            [self.sellPickerView selectRow:[self.dataSource indexOfObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"sell_key"]] inComponent:0 animated:YES];
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
            [self.buyPickerView selectRow:[self.dataSource indexOfObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"buy_key"]] inComponent:0 animated:YES];
            [self.sellPickerView.superview removeFromSuperview];
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

    [self formatGraphData];
    [self.graphView reloadGraph];
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

@end
