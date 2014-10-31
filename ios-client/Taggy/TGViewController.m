//
//  TGViewController.m
//  Test
//
//  Created by Gleb Linkin on 9/29/14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import "TGViewController.h"
#import "TGImageCell.h"
#import "TGData.h"
#import "TGDetailViewController.h"

@interface TGViewController ()

@end

@implementation TGViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Результаты";
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.editButtonItem.title = @"Изменить";
}


-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    if (editing == YES) {
        [self.tableView setEditing:YES animated:YES];
        self.editButtonItem.title = @"Готово";
    }
    else
    {
        [self.tableView setEditing:NO animated:YES];
        self.editButtonItem.title = @"Изменить";
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [TGData currentData].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *const CellId = @"Cell";
    static NSString *const ImageCellId = @"ImageCell";
    TGImageCell *cell = [tableView dequeueReusableCellWithIdentifier:ImageCellId];
    
    TGData *item = [TGData currentData][indexPath.row];
    cell.cellImageView.image = item.image;
    cell.cellAtransfLabel.text = item.Atransf;
    cell.cellBtransfLabel.text = item.Btransf;
    
    return cell;
    
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove the row from data model
    NSArray *currentData = [TGData currentData];
    [TGData removeObject:currentData[indexPath.row]];
    
    // Request table view to reload
    //[tableView reloadData];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Удалить";
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if (indexPath) {
        TGData *item = [[TGData currentData] objectAtIndex:indexPath.row];
        [segue.destinationViewController setDetail:item];
    }
}

@end
