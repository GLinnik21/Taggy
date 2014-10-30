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

@interface TGPriceRecognizer : NSObject

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong, readonly) NSArray *recognizedBlocks;
@property (nonatomic, strong, readonly) NSArray *recognizedPrices;
@property (nonatomic, strong, readonly) NSString *recognizedPlainText;

- (id)initWithLanguage:(NSString *)language;
- (void)recognize;

- (UIImage *)debugImage;

+ (NSArray *)recognizeImage:(UIImage *)image;

@end
