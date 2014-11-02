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

        price = [[TGRecognizedPrice alloc] init];
        price.value = 4.53;
        price.sourceCurrencyCode = @"USD";
        price.defaultCurrency = nil;
        price.rectString = @"";
        [item.prices addObject:price];

        [realm addObject:item];


        item = [[TGPriceImage alloc] init];
        item.captureDate = [NSDate date];
        item.image = [UIImage imageNamed:@"2"];

        price = [[TGRecognizedPrice alloc] init];
        price.value = 110;
        price.sourceCurrencyCode = @"RUB";
        price.defaultCurrency = nil;
        price.rectString = @"";
        [item.prices addObject:price];

        [realm addObject:item];


        item = [[TGPriceImage alloc] init];
        item.captureDate = [NSDate date];
        item.image = [UIImage imageNamed:@"3"];

        price = [[TGRecognizedPrice alloc] init];
        price.value = 24.99;
        price.sourceCurrencyCode = @"EUR";
        price.defaultCurrency = nil;
        price.rectString = @"";
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
    return [TGPriceImage allObjects][index];
}

+ (void)removeRecognizedImage:(TGPriceImage *)recognizedImage
{
    RLMRealm *realm = [RLMRealm defaultRealm];

    [realm beginWriteTransaction];
    [realm deleteObject:recognizedImage];
    [realm commitWriteTransaction];
}

+ (void)recognizeImage:(UIImage *)image withCallback:(void (^)(TGPriceImage *priceImage))callback
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        TGPriceRecognizer *recognizer = [[TGPriceRecognizer alloc] init];
        recognizer.image = image;
        [recognizer recognize];

        TGPriceImage *item = [[TGPriceImage alloc] init];
        item.image = [recognizer debugImage];
        item.captureDate = [NSDate date];

        dispatch_async(dispatch_get_main_queue(), ^{
            RLMRealm *realm = [RLMRealm defaultRealm];

            [realm beginWriteTransaction];

            for (TGRecognizedBlock *block in recognizer.recognizedPrices)
            {
                TGRecognizedPrice *price = [[TGRecognizedPrice alloc] init];
                price.value = [[block number] floatValue];
                price.confidence = block.confidence;
                price.rectString = [NSValue valueWithCGRect:block.region].description;
                price.sourceCurrencyCode = @"BYR"; //TODO: fix hardcode
                price.defaultCurrency = [[self class] defaultCurrency];

                [item.prices addObject:price];
            }
            [realm addObject:item];
            
            [realm commitWriteTransaction];

            if (callback != nil) {
                    callback(item);
            }
        });
        
        [ARAnalytics event:@"Converted"];
    });
}

+ (TGCurrency *)defaultCurrency
{
    return nil;
}

@end
