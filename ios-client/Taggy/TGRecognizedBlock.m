//
//  TGRecognizedBlock.m
//  Taggy
//
//  Created by Nikolay Volosatov on 29.10.14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import "TGRecognizedBlock.h"

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

+ (TGRecognizedBlock *)blockFromDictionary:(NSDictionary *)dict
{
    CGRect rect = [((NSValue *)dict[@"boundingbox"]) CGRectValue];
    CGFloat confidence = [dict[@"confidence"] floatValue];
    NSString *text = dict[@"text"];

    return [[TGRecognizedBlock alloc] initWithRegion:rect confidence:confidence text:text];
}

+ (NSArray *)blocksFromRecognitionArray:(NSArray *)recognition
{
    NSMutableArray *recognizedBlocks = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in recognition) {
        [recognizedBlocks addObject:[TGRecognizedBlock blockFromDictionary:dict]];
    }
    return recognizedBlocks;
}

+ (UIImage *)drawBlocks:(NSArray*)recognizedBlocks onImage:(UIImage *)image
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
        CGRect rect = CGRectMake(or.origin.x, height - or.origin.y,
                                 or.size.width, -or.size.height);
        CGContextStrokeRect(context, rect);
    }

    UIGraphicsPopContext();
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return outputImage;
}

@end
