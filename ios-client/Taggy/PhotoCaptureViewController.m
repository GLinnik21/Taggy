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
#import <CoreData/CoreData.h>

static NSString *const kSendingURL = @"http://taggy-api.bx23.net/Home/Convert";

@interface PhotoCaptureViewController() <NSURLConnectionDelegate>

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
    [self sendImage:image];
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

- (void)sendImage:(UIImage *)sendingImage
{
    //Activate the status bar spinner
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
    
    //The image you want to upload represented in JPEG
    //NOTE: the 'selectedPhoto' needs to be replaced with the UIImage you'd like to upload
    NSData *imageData = UIImageJPEGRepresentation(sendingImage, 1);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:kSendingURL]];
    [request setHTTPMethod:@"POST"];
    
    NSMutableData *body = [NSMutableData data];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    //The file to upload
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: attachment; name=\"file\"; filename=\"image.jpg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:imageData]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    // close the form
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // set request body
    [request setHTTPBody:body];
    
    // Configure your request here.  Set timeout values, HTTP Verb, etc.
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    //Stop the status bar spinner
    app.networkActivityIndicatorVisible = NO;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse object.
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    
    // receivedData is an instance variable declared elsewhere.
    [[[UIAlertView alloc] initWithTitle:@"Отправлено!"
                               message:response.description
                              delegate:nil
                     cancelButtonTitle:@"ОК"
                     otherButtonTitles:nil]show];
    
}

@end
