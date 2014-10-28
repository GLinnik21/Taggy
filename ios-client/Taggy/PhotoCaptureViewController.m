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

    NSNumber *recognizedValue = [self recognizeImage:image];
    NSNumber *converted = @([recognizedValue floatValue] / 35);

    Data *item = [[Data alloc] init];
    item.image = image;
    item.Btransf = [NSString stringWithFormat:@"%@ $", converted];
    item.Atransf = [NSString stringWithFormat:@"%@ руб", recognizedValue];
    [Data addObject:item];
    //[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.dataAr.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.imageview setImage:image];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (NSNumber *)recognizeImage:(UIImage *)imageToRecognize
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
    NSMutableSet *badWords = [[NSMutableSet alloc] init];

    for (NSDictionary *dict in conf) {
        NSNumber *confidence = dict[@"confidence"];
        NSString *data = dict[@"text"];
        CGRect rect = [((NSValue *)dict[@"boundingbox"]) CGRectValue];

        data = [data stringByReplacingOccurrencesOfString:@"," withString:@"."];
        CGFloat value = [data floatValue];
        if (value == 0) {
            if (data.length < 2) {
                [badWords addObject:dict];
            }
            continue;
        }
        if (ABS(rect.size.height) < 30) continue;
        //if (((int)value & 10) != 0 || value < 50) continue;

        [goodWords addObject:dict];
    }

    NSMutableSet *results = [[NSMutableSet alloc] init];

    bool anyFound = false;
    do {
        NSMutableArray *newGoodWords = [[NSMutableArray alloc] initWithArray:goodWords];
        for (NSDictionary *dict in conf) {
            if ([badWords containsObject:dict]) continue;

            NSNumber *confidence = dict[@"confidence"];
            NSString *data = dict[@"text"];
            CGRect rect = [((NSValue *)dict[@"boundingbox"]) CGRectValue];

            for (NSDictionary *exDict in goodWords) {
                NSString *exData = exDict[@"text"];
                CGRect exRect = [((NSValue *)exDict[@"boundingbox"]) CGRectValue];

                CGFloat topDelta = ABS(CGRectGetMinY(rect) - CGRectGetMinY(exRect));
                CGFloat bottomDelta = ABS(CGRectGetMaxY(rect) - CGRectGetMaxY(exRect));
                CGFloat leftDistDelta = ABS(CGRectGetMinX(rect) - CGRectGetMaxX(exRect));
                CGFloat rightDistDelta = ABS(CGRectGetMaxX(rect) - CGRectGetMinX(exRect));

                NSString *unionedResult = nil;
                if (topDelta < 10 && bottomDelta < 10) {
                    if (leftDistDelta > 10 || rightDistDelta > 10) {
                        if (leftDistDelta < 15) {
                            NSLog(@"new word: %@ + %@", exData, data);
                            unionedResult = [exData stringByAppendingString:data];
                        }
                        if (rightDistDelta < 15) {
                            NSLog(@"new word: %@ + %@", data, exData);
                            unionedResult = [data stringByAppendingString:exData];
                        }
                    }
                }

                if (unionedResult != nil) {
                    CGFloat value = [[unionedResult stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
                    [results addObject:@(value)];
                    if ([goodWords containsObject:dict] == NO) {
                        [newGoodWords addObject:dict];
                    }
                }
            }
        }
        goodWords = newGoodWords;
    } while (anyFound);

    [[[UIAlertView alloc] initWithTitle:@"Распознанный текст"
                                message:[[[results objectEnumerator] allObjects] description]
                               delegate:nil
                      cancelButtonTitle:@"ОК"
                      otherButtonTitles:nil]show];
    return [[results allObjects] firstObject];
}

@end
