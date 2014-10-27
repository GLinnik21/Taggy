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
#import <TesseractOCR/Tesseract.h>
#import <CoreImage/CoreImage.h>

static NSString *const kSendingURL = @"http://taggy-api.bx23.net/Home/Convert";

@interface PhotoCaptureViewController() <TesseractDelegate>

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
    image = [UIImage imageNamed:@"3.png"];

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
    tesseract.delegate = self;

    [tesseract setVariableValue:@"0123456789,." forKey:@"tessedit_char_whitelist"];
    [tesseract setImage:imageToRecognize];
    [tesseract recognize];

    NSDictionary *charackterBoxes = tesseract.characterBoxes;
    NSArray *conf = tesseract.getConfidenceByWord;

    conf = [conf sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        NSNumber *cg1 = obj1[@"confidence"];
        NSNumber *cg2 = obj2[@"confidence"];
        return [cg2 compare:cg1];
    }];

    NSMutableArray *goodWords = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in conf) {
        NSNumber *confidence = dict[@"confidence"];
        NSString *data = dict[@"text"];
        CGRect rect = [((NSValue *)dict[@"boundingbox"]) CGRectValue];

        data = [data stringByReplacingOccurrencesOfString:@"," withString:@"."];
        CGFloat value = [data floatValue];
        if (value == 0) continue;
        if (ABS(rect.size.height) < 30) continue;
        //if (((int)value & 10) != 0 || value < 50) continue;

        [goodWords addObject:dict];
    }


    [[[UIAlertView alloc] initWithTitle:@"Распознанный текст"
                                message:[goodWords description]
                               delegate:nil
                      cancelButtonTitle:@"ОК"
                      otherButtonTitles:nil]show];
}

@end
