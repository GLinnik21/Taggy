//
//  TGImageRecognizerHelper.m
//  Taggy
//
//  Created by Nikolay Volosatov on 22.04.15.
//  Copyright (c) 2015 Gleb Linkin. All rights reserved.
//

#import "TGImageRecognizerHelper.h"

#import "TGDataManager.h"
#import "TGDetailViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>

@implementation TGImageRecognizerHelper

+ (void)recognizeImage:(UIImage *)image navigationController:(UINavigationController *)navigationController
{
    [SVProgressHUD setBackgroundColor:[UIColor whiteColor]];
    [SVProgressHUD setForegroundColor:[UIColor orangeColor]];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"recognizing", @"Recognizing")];

    [TGDataManager recognizeImage:image withCallback:^(TGPriceImage *priceImage) {
        if (priceImage.prices.count == 0){
            [SVProgressHUD setBackgroundColor:[UIColor whiteColor]];
            [SVProgressHUD setForegroundColor:[UIColor redColor]];
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"recognizing_fail", @"Failed")];
        }
        else {
            [SVProgressHUD setBackgroundColor:[UIColor whiteColor]];
            [SVProgressHUD setForegroundColor:[UIColor greenColor]];
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"recognized", @"Recognized")];

            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            TGDetailViewController *viewController =
                [storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
            viewController.detail = priceImage;

            UINavigationController *detailNavigationController =
                [[UINavigationController alloc] initWithRootViewController:viewController];

            UIBarButtonItem *dismissButton =
                [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                              target:viewController
                                                              action:@selector(dismiss)];
            viewController.navigationItem.leftBarButtonItem = dismissButton;

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [navigationController presentViewController:detailNavigationController animated:YES completion:nil];
            });
        }
    } progress:^(CGFloat progress) {
        [SVProgressHUD showProgress:progress status:NSLocalizedString(@"recognizing", @"Recognizing")];
    }];
}

@end
