//
//  TGConverterViewController.h
//  Taggy
//
//  Created by Gleb Linkin on 05/02/15.
//  Copyright (c) 2015 Gleb Linkin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TGConverterViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UITextField *sellTextField;
@property (weak, nonatomic) IBOutlet UITextField *buyTextField;
@property (weak, nonatomic) IBOutlet UIButton *sellButton;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;


@end
