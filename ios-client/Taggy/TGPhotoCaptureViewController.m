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
#import <DeviceUtil/DeviceUtil.h>

@interface TGPhotoCaptureViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak) UIImagePickerController *takePhotoPicker;
@property (nonatomic, weak) UIImagePickerController *chooseExistingPicker;

@end

@implementation TGPhotoCaptureViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [ARAnalytics pageView:@"Main"];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [SVProgressHUD dismiss];
}

- (IBAction)takePhoto
{
    Hardware hw = [DeviceUtil hardware];
    BOOL newCamera =
        (hw >= IPHONE_5 && hw < IPOD_TOUCH_1G) ||
        (hw >= IPOD_TOUCH_5G && hw < IPAD) ||
        (hw >= IPAD_2 && hw < IPAD_MINI) ||
        (hw >= IPAD_MINI_RETINA_WIFI && hw < IPAD_AIR_WIFI) ||
        (hw >= IPAD_AIR_WIFI && hw <= SIMULATOR) ||
        hw == NOT_AVAILABLE;

    if (newCamera) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        TGCameraViewController *viewController =
            [storyboard instantiateViewControllerWithIdentifier:@"CameraViewController"];
        viewController.tabNavigationController = self.navigationController;
        [self presentViewController:viewController animated:YES completion:nil];
    }
    else {
        if (hw == SIMULATOR) {
            return;
        }

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
    if ([segue.destinationViewController isKindOfClass:[TGCameraViewController class]]) {
        TGCameraViewController *viewController = segue.destinationViewController;
        viewController.tabNavigationController = self.navigationController;
    }
}

@end
