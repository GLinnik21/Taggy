//
//  Data.h
//  Test
//
//  Created by Gleb Linkin on 10/10/14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Data : NSObject

@property(nonatomic, copy) NSString *Btransf;
@property(nonatomic, copy) NSString *Atransf;
@property(nonatomic, copy) NSString *Transf;
@property(nonatomic, copy) UIImage *image;

+ (NSArray *)currentData;
+ (void)addObject:(id)object;
+ (void)removeObject:(id)object;

@end
