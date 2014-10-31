//
//  TGData.h
//  Taggy
//
//  Created by Gleb Linkin on 10/10/14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TGData : NSObject

@property(nonatomic, copy) NSString *sourcePrice;
@property(nonatomic, copy) NSString *convertedPrice;
@property(nonatomic, strong) UIImage *image;

+ (NSArray *)currentData;
+ (void)addObject:(id)object;
+ (void)removeObject:(id)object;

@end
