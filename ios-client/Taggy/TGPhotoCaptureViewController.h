//
//  TGPhotoCaptureViewController.h
//  Taggy
//
//  Created by Gleb Linkin on 10/14/14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TGPhotoCaptureViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

{
    UIImagePickerController *picker;
    UIImagePickerController *picker2;
    UIImage *image;
    NSArray *_data;
}


-(IBAction)TakePhoto;
-(IBAction)ChooseExisting;
@property (weak, nonatomic) IBOutlet UIButton *TakePhotoButton;

@end
