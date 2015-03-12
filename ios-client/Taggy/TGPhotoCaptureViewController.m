//
//  TGPhotoCaptureViewController.m
//  Taggy
//
//  Created by Gleb Linkin on 10/14/14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import "TGPhotoCaptureViewController.h"

#import <ARAnalytics/ARAnalytics.h>
#import "TGViewController.h"
#import "TGImageCell.h"
#import "TGDataManager.h"
#import "SVProgressHUD.h"
#import "TGDetailViewController.h"
#import <Realm/Realm.h>


@interface TGPhotoCaptureViewController() <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak) UIImagePickerController *takePhotoPicker;
@property (nonatomic, weak) UIImagePickerController *chooseExistingPicker;

@end

@implementation TGPhotoCaptureViewController

-(void)viewDidDisappear:(BOOL)animated{
    [SVProgressHUD dismiss];
}

- (IBAction)takePhoto
{
    if ([[UIDevice currentDevice].model containsString:@"Simulator"] == NO) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
        [self presentViewController:picker animated:YES completion:NULL];
        self.takePhotoPicker = picker;

        [ARAnalytics event:@"Take photo"];
    }
}

- (IBAction)chooseExisting
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:picker animated:YES completion:NULL];
    self.chooseExistingPicker = picker;

    [ARAnalytics event:@"Choose existing photo"];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [SVProgressHUD setBackgroundColor:[UIColor whiteColor]];
    [SVProgressHUD setForegroundColor:[UIColor orangeColor]];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"recognizing", @"Recognizing")];
    if (picker == self.takePhotoPicker) {
        [ARAnalytics event:@"Photo takken"];
    }
    else if (picker == self.chooseExistingPicker) {
        [ARAnalytics event:@"Existing photo choosen"];
    }

    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];

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

            UINavigationController *navigationController =
                [[UINavigationController alloc] initWithRootViewController:viewController];

            UIBarButtonItem *dismissButton =
                [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                              target:viewController
                                                              action:@selector(dismiss)];
            viewController.navigationItem.rightBarButtonItem = dismissButton;
            [viewController.navigationItem.rightBarButtonItem setTintColor:[UIColor orangeColor]];
            
            UIImage *tagImage = [UIImage imageNamed:@"tag"];
            CGRect frameimg = CGRectMake(30, 30, tagImage.size.width, tagImage.size.height);
            UIButton *tagButton = [[UIButton alloc] initWithFrame:frameimg];
            [tagButton setBackgroundImage:tagImage forState:UIControlStateNormal];
            [tagButton addTarget:self action:@selector(saveTag) forControlEvents:UIControlEventTouchUpInside];
            
            UIBarButtonItem *tagBarButton =[[UIBarButtonItem alloc] initWithCustomView:tagButton];
            viewController.navigationItem.leftBarButtonItem = tagBarButton;

            [self.navigationController presentViewController:navigationController animated:YES completion:nil];
        }
    } progress:^(CGFloat progress) {
        [SVProgressHUD showProgress:progress status:NSLocalizedString(@"recognizing", @"Recognizing")];
    }];

    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)saveTag{
    UIAlertView *tagSaveAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"save_tag", @"Save?")
                                                          message:NSLocalizedString(@"save_tag_mess", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel") otherButtonTitles:@"OK", nil];
    tagSaveAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [tagSaveAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *test = [[alertView textFieldAtIndex:0] text];
    if (buttonIndex == 1) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
         //= test;
        [realm commitWriteTransaction];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (picker == self.takePhotoPicker) {
        [ARAnalytics event:@"Photo not takken"];
    }
    else if (picker == self.chooseExistingPicker) {
        [ARAnalytics event:@"Existing photo not choosen"];
    }

    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
