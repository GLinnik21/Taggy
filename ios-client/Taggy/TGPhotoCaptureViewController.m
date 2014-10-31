//
//  TGPhotoCaptureViewController.m
//  Taggy
//
//  Created by Gleb Linkin on 10/14/14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import "TGPhotoCaptureViewController.h"
#import "TGViewController.h"
#import "TGData.h"
#import "TGImageCell.h"
#import <TesseractOCR/Tesseract.h>
#import <CoreImage/CoreImage.h>
#import "TGPriceRecognizer.h"

static NSString *const kSendingURL = @"http://taggy-api.bx23.net/Home/Convert";

@interface TGPhotoCaptureViewController() <TesseractDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *imageview;

@end

@implementation TGPhotoCaptureViewController

-(IBAction)TakePhoto{
    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:picker animated:YES completion:NULL];
}

-(IBAction)ChooseExisting{
    picker2 = [[UIImagePickerController alloc] init];
    picker2.delegate = self;
    [picker2 setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:picker2 animated:YES completion:NULL];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    image = [info objectForKey:UIImagePickerControllerOriginalImage];

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
    item.Btransf = [NSString stringWithFormat:@"%@ $", converted];
    item.Atransf = [NSString stringWithFormat:@"%@ руб", recognizedValue];
    [TGData addObject:item];
    [self.imageview setImage:image];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
