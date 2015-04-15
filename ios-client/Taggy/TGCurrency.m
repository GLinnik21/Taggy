//
//  TGCurrency.m
//  Taggy
//
//  Created by Nikolay Volosatov on 01.11.14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import "TGCurrency.h"

@implementation TGCurrency

+ (NSString *)primaryKey
{
    return @"code";
}

+ (TGCurrency *)currencyForCode:(NSString *)code
{
    return [TGCurrency objectForPrimaryKey:code];
}

@end
