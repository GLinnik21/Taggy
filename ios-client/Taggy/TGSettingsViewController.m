//
//  TGSettingsViewController.m
//  Taggy
//
//  Created by Gleb Linkin on 12/03/15.
//  Copyright (c) 2015 Gleb Linkin. All rights reserved.
//

#import "TGSettingsViewController.h"
#import "TGCurrencyViewController.h"
#import "TGViewController.h"

#import "TGSettingsManager.h"

@interface TGSettingsViewController ()

@property (weak, nonatomic) IBOutlet UITableViewCell *sourceCurrencyCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *targetCurrencyCell;
@property (weak, nonatomic) IBOutlet UILabel *sourceCurrencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *targetCurrencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *privacyCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *siteCell;
@property (weak, nonatomic) IBOutlet UISwitch *auto_updateSwitch;

@end

@implementation TGSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.versionLabel.text = [defaults objectForKey:@"version"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.sourceCurrencyLabel.text = [defaults objectForKey:@"country"];
    self.targetCurrencyLabel.text = [defaults objectForKey:@"transf"];
    
    [self.auto_updateSwitch setOn:[defaults boolForKey:@"auto_update"] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *theCellClicked = [self.tableView cellForRowAtIndexPath:indexPath];
    if (theCellClicked == self.siteCell) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://taggy.by"]];
    }
    if (theCellClicked == self.privacyCell) {
        if (&UIApplicationOpenSettingsURLString != NULL) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }
    if (theCellClicked == self.sourceCurrencyCell) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        TGCurrencyViewController *currency = [storyboard instantiateViewControllerWithIdentifier:@"CurrenciesViewController"];
        currency.settingsKey = kTGSettingsSourceCurrencyKey;
        [self.navigationController pushViewController:currency animated:YES];
    }
    if (theCellClicked == self.targetCurrencyCell) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        TGCurrencyViewController *currency = [storyboard instantiateViewControllerWithIdentifier:@"CurrenciesViewController"];
        currency.settingsKey = kTGSettingsTargetCurrencyKey;
        [self.navigationController pushViewController:currency animated:YES];
    }
    
}

- (IBAction)auto_updateSwitchAction:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:@"auto_update"]) {
        [defaults setBool:YES forKey:@"auto_update"];
    }else{
        [defaults setBool:NO forKey:@"auto_update"];
    }
}


/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
