//
//  TGRecognizedPrice.m
//  Taggy
//
//  Created by Nikolay Volosatov on 01.11.14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import "TGRecognizedPrice.h"

@implementation TGRecognizedPrice

- (CGFloat)convertedPrice
{
    CGFloat sourceRate = 1.0f;
    CGFloat targetRate = 1.0f;
    
    if (self.sourceCurrency != nil) {
        sourceRate = self.sourceCurrency.value;
    }
    if (self.defaultCurrency != nil) {
        targetRate = self.defaultCurrency.value;
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
    return [NSString stringWithFormat:@"%.2f %@", [self convertedPrice], [self currencyName:self.defaultCurrency]];
}

@end
