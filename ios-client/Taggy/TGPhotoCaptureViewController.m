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
#import "TGData.h"
#import "TGImageCell.h"
#import "TGPriceRecognizer.h"

@interface TGPhotoCaptureViewController() <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *imageview;
@property (weak, nonatomic) IBOutlet UIButton *takePhotoButton;

@property (nonatomic, weak) UIImagePickerController *takePhotoPicker;
@property (nonatomic, weak) UIImagePickerController *chooseExistingPicker;

@end

@implementation TGPhotoCaptureViewController

- (IBAction)takePhoto
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:picker animated:YES completion:NULL];
    self.takePhotoPicker = picker;

    [ARAnalytics event:@"Take photo"];
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

    TGPriceRecognizer *recognizer = [[TGPriceRecognizer alloc] init];
    recognizer.image = image;
    [recognizer recognize];

    image = [recognizer debugImage];

    NSArray *recognized = recognizer.recognizedPrices;
    NSNumber *recognizedValue = [recognized firstObject];
    NSNumber *converted = @([recognizedValue floatValue] / 35);

    [[[UIAlertView alloc] initWithTitle:@"Распознанные цены"
                                message:[[recognizer recognizedPrices] description]
                               delegate:nil
                      cancelButtonTitle:@"ОК"
                      otherButtonTitles:nil]show];

    TGData *item = [[TGData alloc] init];
    item.image = image;
    item.convertedPrice = [NSString stringWithFormat:@"%@ $", converted];
    item.sourcePrice = [NSString stringWithFormat:@"%@ руб", recognizedValue];

    [ARAnalytics event:@"Converted"
        withProperties:@{ @"from" : item.sourcePrice, @"to" : item.convertedPrice}];
    
    [TGData addObject:item];
    [self.imageview setImage:image];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
