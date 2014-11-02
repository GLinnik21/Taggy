//
//  TGData.m
//  Taggy
//
//  Created by Gleb Linkin on 10/10/14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import "TGData.h"

@implementation TGData

+ (NSArray *)CData
{
    NSMutableArray *result = [NSMutableArray array];
    
    TGData *item;
    
    item = [[TGData alloc] init];
    item.convertedPrice = @"$4.53";
    item.sourcePrice = @"48400р.";
    item.image = [UIImage imageNamed:@"1"];
    [result addObject:item];
    
    item = [[TGData alloc] init];
    item.convertedPrice = @"₽110";
    item.sourcePrice = @"29100р.";
    item.image = [UIImage imageNamed:@"2"];
    [result addObject:item];
    
    item = [[TGData alloc] init];
    item.convertedPrice = @"€24.99";
    item.sourcePrice = @"337000р.";
    item.image = [UIImage imageNamed:@"3"];
    [result addObject:item];
    
    return result;
}

+ (NSArray *)currentData
{
    return [[self class] mutableCurrentData];
}

+ (NSMutableArray *)mutableCurrentData
{
    static NSMutableArray *ar = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        ar = [[[self class] CData] mutableCopy];
    });
    return ar;
}

+ (void)addObject:(id)object
{
    NSMutableArray *ar = [[self class] mutableCurrentData];
    [ar addObject:object];
}

+ (void)removeObject:(id)object
{
    NSMutableArray *ar = [[self class] mutableCurrentData];
    [ar removeObject:object];
}

@end
