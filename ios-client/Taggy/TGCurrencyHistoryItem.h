//
//  TGCurrencyHistoryItem.h
//  Taggy
//
//  Created by Nikolay Volosatov on 17.04.15.
//  Copyright (c) 2015 Gleb Linkin. All rights reserved.
//

#import <Realm/Realm.h>

@interface TGCurrencyHistoryItem : RLMObject

@property NSDate *date;
@property CGFloat value;

@end

// RLMArray<TGCurrencyHistoryItem>
RLM_ARRAY_TYPE(TGCurrencyHistoryItem)
