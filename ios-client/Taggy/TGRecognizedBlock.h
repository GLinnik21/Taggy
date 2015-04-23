//
//  TGRecognizedBlock.h
//  Taggy
//
//  Created by Nikolay Volosatov on 29.10.14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class G8RecognizedBlock;

@interface TGRecognizedBlock : NSObject

@property (nonatomic, assign) CGRect region;
@property (nonatomic, assign) CGFloat confidence;
@property (nonatomic, copy) NSString *text;

- (id)initWithRegion:(CGRect)region confidence:(CGFloat)confidence text:(NSString *)text;

- (NSNumber *)number;

+ (TGRecognizedBlock *)blockFromG8Block:(G8RecognizedBlock *)block;
+ (NSArray *)blocksFromRecognitionArray:(NSArray *)recognition;
+ (UIImage *)drawBlocks:(NSArray *)recognizedBlocks onImage:(UIImage *)image;

@end
