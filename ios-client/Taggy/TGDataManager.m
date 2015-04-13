//
//  TGDataManager.m
//  Taggy
//
//  Created by Nikolay Volosatov on 02.11.14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import "TGDataManager.h"
#import "TGPriceRecognizer.h"
#import "TGPriceImage.h"
#import "TGSettingsManager.h"
#import <ARAnalytics/ARAnalytics.h>

@implementation TGDataManager

+ (void)fillSample
{
    RLMRealm *realm = [RLMRealm defaultRealm];

    [realm beginWriteTransaction];

    if ([[self class] recognizedImagesCount] == 0) {
        TGPriceImage *item;
        TGRecognizedPrice *price;

        item = [[TGPriceImage alloc] init];
        item.captureDate = [NSDate date];
        item.image = [UIImage imageNamed:@"1"];
        item.tag = @"Vogel";

        price = [[TGRecognizedPrice alloc] init];
        price.value = 4.53;
        price.sourceCurrency = nil;
        price.defaultCurrency = [TGCurrency currencyForCode:@"BYR"];
        price.rect = CGRectZero;
        [item.prices addObject:price];

        [realm addObject:item];


        item = [[TGPriceImage alloc] init];
        item.captureDate = [NSDate date];
        item.image = [UIImage imageNamed:@"2"];
        item.tag = @"Пивас";
        
        price = [[TGRecognizedPrice alloc] init];
        price.value = 110;
        price.sourceCurrency = [TGCurrency currencyForCode:@"RUB"];
        price.defaultCurrency = [TGCurrency currencyForCode:@"BYR"];
        price.rect = CGRectZero;
        [item.prices addObject:price];

        [realm addObject:item];


        item = [[TGPriceImage alloc] init];
        item.captureDate = [NSDate date];
        item.image = [UIImage imageNamed:@"3"];
        item.tag = @"Памперсы";
        
        price = [[TGRecognizedPrice alloc] init];
        price.value = 24.99;
        price.sourceCurrency = [TGCurrency currencyForCode:@"EUR"];
        price.defaultCurrency = [TGCurrency currencyForCode:@"BYR"];
        price.rect = CGRectZero;
        [item.prices addObject:price];

        [realm addObject:item];
    }

    [realm commitWriteTransaction];
}

+ (NSInteger)recognizedImagesCount
{
    return [TGPriceImage allObjects].count;
}

+ (TGPriceImage *)recognizedImageAtIndex:(NSInteger)index
{
    return [[TGPriceImage allObjects] sortedResultsUsingProperty:@"captureDate" ascending:NO][index];
}

+ (BOOL)removeRecognizedImage:(TGPriceImage *)recognizedImage
{
    RLMRealm *realm = [RLMRealm defaultRealm];

    BOOL success = YES;
    @try {
        [realm beginWriteTransaction];
        [realm deleteObject:recognizedImage];
        [realm commitWriteTransaction];
    }
    @catch (NSException *exception) {
        DDLogError(@"Can't delete object");
        success = NO;
    }

    return success;
}

+ (BOOL)deleteAllObjects
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    BOOL success = YES;
    @try {
        [realm beginWriteTransaction];
        [realm deleteAllObjects];
        [realm commitWriteTransaction];
    }
    @catch (NSException *exception) {
        DDLogError(@"Can't delete all objects");
        success = NO;
    }
    
    return success;
}

+ (NSOperationQueue *)sharedQueue
{
    static NSOperationQueue *queue = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[NSOperationQueue alloc] init];
    });
    return queue;
}

+ (void)recognizeImage:(UIImage *)image
          withCallback:(void (^)(TGPriceImage *priceImage))callback
              progress:(void (^)(CGFloat progress))progress
{
    TGPriceRecognizer *recognizer = [[TGPriceRecognizer alloc] init];
    recognizer.progressBlock = progress;
    recognizer.image = image;
    
    __weak typeof(self) weakSelf = self;
    [[[self class] sharedQueue] addOperationWithBlock:^{
        
        [recognizer recognize];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            TGPriceImage *item = [[TGPriceImage alloc] init];
            item.image = recognizer.image;
            item.captureDate = [NSDate date];

            if (recognizer.recognizedPrices.count > 0) {
                RLMRealm *realm = [RLMRealm defaultRealm];

                [realm beginWriteTransaction];

                for (TGRecognizedBlock *block in recognizer.recognizedPrices)
                {
                    TGRecognizedPrice *price = [[TGRecognizedPrice alloc] init];
                    price.value = [[block number] floatValue];
                    price.confidence = block.confidence;

                    CGRect rect =
                        CGRectApplyAffineTransform(block.region,
                                                   CGAffineTransformScale(CGAffineTransformIdentity,
                                                                          item.image.size.width, item.image.size.height));
                    price.rect = rect;
                    price.sourceCurrency = [[strongSelf class] sourceCurrency];
                    price.defaultCurrency = [[strongSelf class] transferCurrency];

                    [item.prices addObject:price];
                }
                [realm addObject:item];
                
                [realm commitWriteTransaction];
            }

            if (callback != nil) {
                callback(item);
            }
            [ARAnalytics event:@"Converted"];
        }];
    }];
}

+ (TGCurrency *)sourceCurrency
{
    NSString *code = [TGSettingsManager objectForKey:kTGSettingsSourceCurrencyKey];
    if (code == nil) {
        code = @"BYR";
    }
    if ([code isEqualToString:@"USD"]) {
        return nil;
    }
    return [TGCurrency currencyForCode:code];
}

+ (TGCurrency *)transferCurrency
{
    NSString *code = [TGSettingsManager objectForKey:kTGSettingsTargetCurrencyKey];
    if (code == nil || [code isEqualToString:@"USD"]) {
        return nil;
    }
    return [TGCurrency currencyForCode:code];
}

@end
