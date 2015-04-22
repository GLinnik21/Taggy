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
#import "TGImageRecognizerHelper.h"
#import "SVProgressHUD.h"
#import "TGCameraViewController.h"
#import <Realm/Realm.h>


@interface TGPhotoCaptureViewController() <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak) UIImagePickerController *takePhotoPicker;
@property (nonatomic, weak) UIImagePickerController *chooseExistingPicker;

@end

@implementation TGPhotoCaptureViewController

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [SVProgressHUD dismiss];
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
    if (picker == self.takePhotoPicker) {
        [ARAnalytics event:@"Photo takken"];
    }
    else if (picker == self.chooseExistingPicker) {
        [ARAnalytics event:@"Existing photo choosen"];
    }

    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];

    [TGImageRecognizerHelper recognizeImage:image navigationController:self.navigationController];

    [self dismissViewControllerAnimated:YES completion:nil];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[TGCameraViewController class]])
    {
        TGCameraViewController *viewController = segue.destinationViewController;
        viewController.tabNavigationController = self.navigationController;
    }
}

@end
