//
//  Data.m
//  Test
//
//  Created by Gleb Linkin on 10/10/14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import "Data.h"

@implementation Data

+ (NSArray *)CData
{
    NSMutableArray *result = [NSMutableArray array];
    
    Data *item;
    
    item = [[Data alloc] init];
    item.Btransf = @"$4.53";
    item.Atransf = @"BYR48400";
    item.image = [UIImage imageNamed:@"1"];
    [result addObject:item];
    
    item = [[Data alloc] init];
    item.Btransf = @"₽110";
    item.Atransf = @"BYR29100";
    item.image = [UIImage imageNamed:@"2"];
    [result addObject:item];
    
    item = [[Data alloc] init];
    item.Btransf = @"€24.99";
    item.Atransf = @"BYR337000";
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
