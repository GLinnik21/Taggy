//
//  TGImageRecognizerHelper.h
//  Taggy
//
//  Created by Nikolay Volosatov on 22.04.15.
//  Copyright (c) 2015 Gleb Linkin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TGImageRecognizerHelper : NSObject

+ (void)recognizeImage:(UIImage *)image navigationController:(UINavigationController *)navigationController;

@end
