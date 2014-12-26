//
//  TGPriceRecognizer.h
//  Taggy
//
//  Created by Nikolay Volosatov on 30.10.14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TGRecognizedBlock.h"

typedef void(^TGRecognitionProgress)(CGFloat progress);

@interface TGPriceRecognizer : NSObject

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong, readonly) NSArray *recognizedBlocks;
@property (nonatomic, strong, readonly) NSArray *recognizedPrices;
@property (nonatomic, strong, readonly) NSString *recognizedPlainText;

@property (nonatomic, copy) TGRecognitionProgress progressBlock;

- (id)initWithLanguage:(NSString *)language;
- (void)recognize;

- (UIImage *)debugImage;

+ (NSArray *)recognizeImage:(UIImage *)image;

@end
