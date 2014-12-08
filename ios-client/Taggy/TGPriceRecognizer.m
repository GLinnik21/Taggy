//
//  TGPriceRecognizer.m
//  Taggy
//
//  Created by Nikolay Volosatov on 30.10.14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import "TGPriceRecognizer.h"
#import "TGCommon.h"
#import <TesseractOCR/Tesseract.h>
#import <CoreImage/CoreImage.h>
#import <ARAnalytics/ARAnalytics.h>
#import <GPUImage/GPUImage.h>
#import "UIImage+FixOrientation.h"

static NSString *const kTGNumberRegexPattern = @"([0-9]*|[0-9]+[,.])([,.][0-9]+|[0-9]+)";

static CGFloat const kTGMinimalBlockConfidence = 10.0f;
static CGFloat const kTGMinimalBlockHeight = 20.0f;
static CGFloat const kTGMaximalConfidenceDelta = 25.0f;
static NSUInteger const kTGMaximumPriceLength = 10;
static CGFloat const kTGMinimumPriceValue = 10.0f;
static NSUInteger const kTGMaximumPricesCount = 4;

@interface TGPriceRecognizer()

@property (nonatomic, strong) NSArray *recognizedBlocks;
@property (nonatomic, strong) NSArray *recognizedPrices;

@property (nonatomic, strong) Tesseract *tesseract;
@property (nonatomic, strong) NSArray *wellRecognizedBlocks;

@end

@implementation TGPriceRecognizer

- (id)init
{
    return [self initWithLanguage:@"rus"];
}

- (id)initWithLanguage:(NSString *)language
{
    self = [super init];
    if (self != nil) {
        _tesseract = [[Tesseract alloc] initWithLanguage:language];

        NSDictionary *params = @{
            //@"textord_noise_normratio": @"5",
            @"textord_heavy_nr": @"1",
            //@"textord_projection_scale": @"0.25",
            //@"tessedit_minimal_rejection": @"1",
            @"textord_parallel_baselines": @"0",
            @"tessedit_char_whitelist": @"0123456789,.-",
            //@"tessedit_char_blacklist": @"@#%^&*{}_\\/",
            @"classify_bln_numeric_mode": @"6",
            //@"matcher_avg_noise_size": @"22",
        };

        for (NSString *key in params.allKeys) {
            [_tesseract setVariableValue:params[key] forKey:key];
        }
    }
    return self;
}

+ (UIImage *)binarizeImage:(UIImage *)sourceImage andResize:(CGSize)size
{
    GPUImageAverageLuminanceThresholdFilter *filter = [[GPUImageAverageLuminanceThresholdFilter alloc] init];
    //filter.thresholdMultiplier = 1.1;
    filter.thresholdMultiplier = 0.5;

    [filter forceProcessingAtSizeRespectingAspectRatio:size];

    UIImage *resultImage = [filter imageByFilteringImage:sourceImage];
    return resultImage;
}

+ (UIImage *)imageAfterPreprocessingImage:(UIImage *)image
{
    image = [image fixOrientation];
    image = [[self class] binarizeImage:image andResize:CGSizeMake(600, 600)];

    return image;
}

- (void)setImage:(UIImage *)image
{
    if (_image != image) {
        _image = [TGCommon imageWithImage:image scaledToSizeWithSameAspectRatio:CGSizeMake(600, 600)];

        self.tesseract.image = [[self class] imageAfterPreprocessingImage:image];
    }
}

- (NSString *)recognizedPlainText
{
    return self.tesseract.recognizedText;
}

- (void)clear
{
    self.wellRecognizedBlocks = nil;
    self.recognizedPrices = nil;
}

- (void)recognize
{
    [ARAnalytics startTimingEvent:@"Recognizing image"];

    @try {
        [self clear];

        [self.tesseract recognize];
        self.recognizedBlocks = [TGRecognizedBlock blocksFromRecognitionArray:self.tesseract.getConfidenceByWord];
        self.wellRecognizedBlocks = self.recognizedBlocks;


        //[self removeBadRecognizedBlocks];
        [self splitBlocks];
        //[self removeSmallBlocks];
        [self sortBlocks];
        [self takeFirst:INT_MAX];
        [self joinBlocks];
        [self removeBadPrices];
        [self belarusOptimization];
        [self sortBlocks];
        [self takeFirst:kTGMaximumPricesCount];

        [self formatPrices];
        NSLog(@"Prices: %@", self.recognizedPrices);

        [ARAnalytics event:@"Image recognized"
            withProperties:@{@"count": @(self.recognizedPrices.count)}];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@", exception.description);

        [ARAnalytics error:[NSError errorWithDomain:@"Tesseract"
                                               code:NSExecutableRuntimeMismatchError
                                           userInfo:@{ @"description" : exception.description }]
               withMessage:@"Recognition exception"];

        [self clear];
    }
    @finally {
        [ARAnalytics finishTimingEvent:@"Recognizing image"];
    }
}

- (void)sortBlocks
{
    self.wellRecognizedBlocks = [self.wellRecognizedBlocks sortedArrayUsingComparator:
                                 ^NSComparisonResult(TGRecognizedBlock *obj1, TGRecognizedBlock *obj2) {
        return obj2.confidence - obj1.confidence;
    }];
}

- (void)splitBlocks
{
    NSMutableArray *newBlocks = [[NSMutableArray alloc] initWithCapacity:self.wellRecognizedBlocks.count];
    for (TGRecognizedBlock *block in self.wellRecognizedBlocks) {
        NSString *text = block.text;

        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:kTGNumberRegexPattern
                                                                               options:0
                                                                                 error:&error];
        if (error == nil) {
            CGFloat deltaX = CGRectGetWidth(block.region) / block.text.length;

            [regex enumerateMatchesInString:text
                                    options:0
                                      range:NSMakeRange(0, text.length)
                                 usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                     NSString *newText = [text substringWithRange:result.range];
                                     CGRect region =
                                         CGRectMake(CGRectGetMinX(block.region) + deltaX * result.range.location,
                                                    CGRectGetMinY(block.region),
                                                    deltaX * result.range.length,
                                                    CGRectGetHeight(block.region));

                                     TGRecognizedBlock *newBlock =
                                        [[TGRecognizedBlock alloc] initWithRegion:region
                                                                       confidence:block.confidence
                                                                             text:newText];
                                     [newBlocks addObject:newBlock];
            }];
        }
    }
    self.wellRecognizedBlocks = newBlocks;
}

- (void)removeBadRecognizedBlocks
{
    NSMutableArray *newBlocks = [[NSMutableArray alloc] initWithCapacity:self.wellRecognizedBlocks.count];
    for (TGRecognizedBlock *block in self.wellRecognizedBlocks) {
        if (block.confidence < kTGMinimalBlockConfidence) continue;

        [newBlocks addObject:block];
    }
    self.wellRecognizedBlocks = newBlocks;
}

- (void)removeSmallBlocks
{
    NSMutableArray *newBlocks = [[NSMutableArray alloc] initWithCapacity:self.wellRecognizedBlocks.count];
    for (TGRecognizedBlock *block in self.wellRecognizedBlocks) {
        if (ABS(CGRectGetHeight(block.region)) < kTGMinimalBlockHeight) continue;

        [newBlocks addObject:block];
    }
    self.wellRecognizedBlocks = newBlocks;
}

- (void)joinBlocks
{
    BOOL anyFound = NO;
    do {
        anyFound = NO;
        NSMutableArray *newGoodWords = [[NSMutableArray alloc] initWithArray:self.wellRecognizedBlocks];
        for (TGRecognizedBlock *block in self.wellRecognizedBlocks) {
            if ([newGoodWords containsObject:block] == NO) continue;
            for (TGRecognizedBlock *exBlock in self.wellRecognizedBlocks) {
                if ([newGoodWords containsObject:exBlock] == NO) continue;
                if (block == exBlock) continue;

                CGFloat topDelta = ABS(CGRectGetMinY(block.region) - CGRectGetMinY(exBlock.region));
                CGFloat bottomDelta = ABS(CGRectGetMaxY(block.region) - CGRectGetMaxY(exBlock.region));
                CGFloat leftDistDelta = ABS(CGRectGetMinX(block.region) - CGRectGetMaxX(exBlock.region));
                CGFloat rightDistDelta = ABS(CGRectGetMaxX(block.region) - CGRectGetMinX(exBlock.region));
                CGFloat confDelta = ABS(block.confidence - exBlock.confidence);

                if (confDelta > kTGMaximalConfidenceDelta) continue;

                CGFloat maxVDelta = (CGRectGetHeight(block.region) + CGRectGetHeight(exBlock.region)) * 0.5;
                if (topDelta > maxVDelta || bottomDelta > maxVDelta) continue;

                CGFloat maxHDelta = MIN(CGRectGetHeight(block.region), CGRectGetHeight(exBlock.region)) * 0.85;
                if (leftDistDelta < maxHDelta && rightDistDelta < maxHDelta) continue;

                TGRecognizedBlock *unionedResult = nil;
                if (leftDistDelta < maxHDelta) {
                    NSLog(@"new word: %@ + %@", exBlock.text, block.text);
                    unionedResult =
                        [[TGRecognizedBlock alloc] initWithRegion:CGRectUnion(exBlock.region, block.region)
                                                       confidence:MIN(exBlock.confidence, block.confidence)
                                                             text:[exBlock.text stringByAppendingString:block.text]];
                }
                else if (rightDistDelta < maxHDelta) {
                    NSLog(@"new word: %@ + %@", block.text, exBlock.text);
                    unionedResult =
                        [[TGRecognizedBlock alloc] initWithRegion:CGRectUnion(exBlock.region, block.region)
                                                       confidence:MIN(exBlock.confidence, block.confidence)
                                                             text:[block.text stringByAppendingString:exBlock.text]];
                }

                if (unionedResult != nil) {
                    [newGoodWords removeObject:block];
                    [newGoodWords removeObject:exBlock];
                    [newGoodWords addObject:unionedResult];

                    anyFound = YES;
                    break;
                }
            }
        }
        self.wellRecognizedBlocks = newGoodWords;
    } while (anyFound);
}

- (void)removeBadPrices
{
    NSMutableArray *newBlocks = [[NSMutableArray alloc] initWithCapacity:self.wellRecognizedBlocks.count];
    for (TGRecognizedBlock *block in self.wellRecognizedBlocks) {
        if (block.text.length > kTGMaximumPriceLength) continue;
        if ([[block number] floatValue] < kTGMinimumPriceValue) continue;

        [newBlocks addObject:block];
    }
    self.wellRecognizedBlocks = newBlocks;
}

- (void)belarusOptimization
{
    NSMutableArray *newBlocks = [[NSMutableArray alloc] initWithCapacity:self.wellRecognizedBlocks.count];
    for (TGRecognizedBlock *block in self.wellRecognizedBlocks) {
        if ([[block.text substringFromIndex:block.text.length-1] isEqualToString:@"0"] == NO) continue;

        [newBlocks addObject:block];
    }
    self.wellRecognizedBlocks = newBlocks;
}

- (void)takeFirst:(NSUInteger)count
{
    NSMutableArray *newBlocks = [[NSMutableArray alloc] initWithCapacity:self.wellRecognizedBlocks.count];
    CGFloat maxConfidence = ((TGRecognizedBlock *)self.wellRecognizedBlocks.firstObject).confidence;
    for (TGRecognizedBlock *block in self.wellRecognizedBlocks) {
        if (count <= 0) break;
        if (ABS(block.confidence - maxConfidence) > kTGMaximalConfidenceDelta) break;

        [newBlocks addObject:block];
        --count;
    }
    self.wellRecognizedBlocks = newBlocks;
}

- (void)formatPrices
{
    self.recognizedPrices = self.wellRecognizedBlocks;
}

- (UIImage *)debugImage
{
    return [TGRecognizedBlock drawBlocks:self.wellRecognizedBlocks onImage:self.image];
}

+ (NSArray *)recognizeImage:(UIImage *)image
{
    TGPriceRecognizer *recognizer = [[TGPriceRecognizer alloc] init];
    recognizer.image = image;
    [recognizer recognize];
    
    return recognizer.recognizedPrices;
}

@end
