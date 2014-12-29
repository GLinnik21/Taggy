//
//  TGRecognizedBlock.m
//  Taggy
//
//  Created by Nikolay Volosatov on 29.10.14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import "TGRecognizedBlock.h"
#import <TesseractOCR/TesseractOCR.h>

@implementation TGRecognizedBlock

- (id)initWithRegion:(CGRect)region confidence:(CGFloat)confidence text:(NSString *)text
{
    self = [super init];
    if (self != nil) {
        _region = region;
        _confidence = confidence;
        _text = [text copy];
    }
    return self;
}

- (NSNumber *)number
{
    CGFloat value = [[self.text stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
    return @(value);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%dp %@ in %@",
            (int)self.confidence,
            self.text,
            [NSValue valueWithCGRect:self.region]];
}

+ (TGRecognizedBlock *)blockFromG8Block:(G8RecognizedBlock *)block
{
    return [[TGRecognizedBlock alloc] initWithRegion:block.boundingBox
                                          confidence:block.confidence
                                                text:block.text];
}

+ (NSArray *)blocksFromRecognitionArray:(NSArray *)recognition
{
    NSMutableArray *recognizedBlocks = [[NSMutableArray alloc] init];
    for (G8RecognizedBlock *block in recognition) {
        [recognizedBlocks addObject:[TGRecognizedBlock blockFromG8Block:block]];
    }
    return recognizedBlocks;
}

+ (UIImage *)drawBlocks:(NSArray *)recognizedBlocks onImage:(UIImage *)image
{
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), YES, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);

    [image drawInRect:CGRectMake(0, 0, width, height)];

    CGContextSetLineWidth(context, 2.0f);
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);

    for (TGRecognizedBlock *block in recognizedBlocks) {
        CGRect or = block.region;
        CGRect rect = CGRectMake(or.origin.x, or.origin.y,
                                 or.size.width, or.size.height);
        CGContextStrokeRect(context, rect);

        NSAttributedString *string = [[NSAttributedString alloc] initWithString:block.text attributes:@{
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
