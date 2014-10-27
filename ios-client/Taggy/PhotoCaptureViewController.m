//
//  PhotoCaptureViewController.m
//  Test
//
//  Created by Gleb Linkin on 10/14/14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import "PhotoCaptureViewController.h"
#import "ViewController.h"
#import "Data.h"
#import "imageCell.h"
#import <TesseractOCR/TesseractOCR.h>

static NSString *const kSendingURL = @"http://taggy-api.bx23.net/Home/Convert";

@interface PhotoCaptureViewController()

@property (nonatomic, weak) IBOutlet UIImageView *imageview;

@end

@implementation PhotoCaptureViewController

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

    [self recognizeImage:image];

    Data *item = [[Data alloc] init];
    item.image = image;
    item.Btransf = @"$";
    item.Atransf = @"%";
    [Data addObject:item];
    //[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.dataAr.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.imageview setImage:image];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)recognizeImage:(UIImage *)imageToRecognize
{
    Tesseract* tesseract = [[Tesseract alloc] initWithLanguage:@"rus"];
    [tesseract setImage:imageToRecognize];
    [tesseract recognize];

    [[[UIAlertView alloc] initWithTitle:@"Распознанный текст"
                                message:[tesseract recognizedText]
                               delegate:nil
                      cancelButtonTitle:@"ОК"
                      otherButtonTitles:nil]show];
}

@end
