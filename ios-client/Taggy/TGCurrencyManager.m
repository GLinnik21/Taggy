//
//  TGCurrencyManager.m
//  Taggy
//
//  Created by Nikolay Volosatov on 10.11.14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import "TGCurrencyManager.h"
#import <Realm/Realm.h>
#import "TGCurrency.h"

@implementation TGCurrencyManager

+ (void)update
{
    NSError *error;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"currency" ofType:@"json"];
    NSInputStream *inputStream = [NSInputStream inputStreamWithFileAtPath:filePath];
    [inputStream open];
    NSArray *currencyRates = [NSJSONSerialization JSONObjectWithStream:inputStream options:0 error:&error];

    NSDate *nowDate = [NSDate date];
    RLMRealm *realm = [RLMRealm defaultRealm];

    for (NSDictionary *currency in currencyRates) {
        NSString *codeFrom = currency[@"From"];
        NSString *codeTo = currency[@"To"];
        CGFloat rate = [currency[@"Rate"] floatValue];

        [realm transactionWithBlock:^{
            RLMResults *existsRates = [TGCurrency objectsWhere:@"codeFrom == %@ && codeTo == %@", codeFrom, codeTo];
            TGCurrency *tgCurrency = existsRates.firstObject;

            if (tgCurrency != nil) {
                tgCurrency.value = rate;
                tgCurrency.updateDate = nowDate;
            }
            else {
                tgCurrency = [[TGCurrency alloc] init];

                tgCurrency.codeFrom = codeFrom;
                tgCurrency.codeTo = codeTo;
                tgCurrency.value = rate;
                tgCurrency.updateDate = nowDate;

                [realm addObject:tgCurrency];
            }
        }];
    }
}

@end
