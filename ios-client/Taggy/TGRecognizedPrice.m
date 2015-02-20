//
//  TGRecognizedPrice.m
//  Taggy
//
//  Created by Nikolay Volosatov on 01.11.14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import "TGRecognizedPrice.h"
#import "TGDataManager.h"

@implementation TGRecognizedPrice

+ (NSArray *)ignoredProperties
{
    return @[@"rect"];
}

- (CGRect)rect
{
    NSValue *rectValue = [NSKeyedUnarchiver unarchiveObjectWithData:self.rectData];
    return [rectValue CGRectValue];
}

- (void)setRect:(CGRect)rect
{
    NSValue *rectValue = [NSValue valueWithCGRect:rect];
    self.rectData = [NSKeyedArchiver archivedDataWithRootObject:rectValue];
}

- (TGCurrency *)targetCurency
{
    return [TGDataManager transferCurrency];
}

- (CGFloat)convertedPrice
{
    CGFloat sourceRate = 1.0f;
    CGFloat targetRate = 1.0f;
    
    if (self.sourceCurrency != nil) {
        sourceRate = self.sourceCurrency.value;
    }
    if ([self targetCurency] != nil) {
        targetRate = [self targetCurency].value;
    }

    return self.value * sourceRate / targetRate;
}

- (NSString *)currencyName:(TGCurrency *)currency
{
    if (currency == nil) {
        return @"USD";
    }
    return currency.codeFrom;
}

- (NSString *)formattedSourcePrice
{
    return [NSString stringWithFormat:@"%.2f %@", self.value, [self currencyName:self.sourceCurrency]];
}

- (NSString *)formattedConvertedPrice
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults objectForKey:@"transf"]  isEqual:@"BYR"]) {
        return [NSString stringWithFormat:@"%0.0f %@", [self convertedPrice], [self currencyName:[self targetCurency]]];
    }
    return [NSString stringWithFormat:@"%.2f %@", [self convertedPrice], [self currencyName:[self targetCurency]]];
}

+ (UIImage *)drawPrices:(NSArray *)prices onImage:(UIImage *)image
{
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), YES, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);

    [image drawInRect:CGRectMake(0, 0, width, height)];

    CGContextSetLineWidth(context, 2.0f);
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);

    for (TGRecognizedPrice *price in prices) {
        CGRect or = price.rect;
        CGRect rect = CGRectMake(or.origin.x, or.origin.y,
                                 or.size.width, or.size.height);
        CGContextStrokeRect(context, rect);

        NSString *value = [NSString stringWithFormat:@"%.00f", price.value];
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:value attributes:@{
            NSForegroundColorAttributeName: [UIColor redColor]
        }];
        [string drawAtPoint:(CGPoint){CGRectGetMidX(rect), CGRectGetMaxY(rect) + 2}];
    }
    
    UIGraphicsPopContext();
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}

@end
