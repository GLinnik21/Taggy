//
//  TGFavouriteCurrencies.h
//  Taggy
//
//  Created by Gleb Linkin on 08/05/15.
//  Copyright (c) 2015 Gleb Linkin. All rights reserved.
//

#import "RLMObject.h"
#import <Realm/Realm.h>

@interface TGFavouriteCurrencies : RLMObject

@property NSString *code;

+(NSArray *)fetchData;

@end
