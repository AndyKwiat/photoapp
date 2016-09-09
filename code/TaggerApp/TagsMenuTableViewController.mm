//
//  TagsMenuTableViewController.m
//  Tagger
//
//  Created by Andy Kwiatkowski on 2016-01-22.
//
//

#include"Tag.h"
#import "TagsMenuTableViewController.h"
#import "TagsMenuCell.h"
#include "Connector.hpp"
@interface TagsMenuTableViewController ()
@property (nonatomic, strong) IBOutlet UILabel *photoCountLabel;
@end

@implementation TagsMenuTableViewController
static NSString * const CellReuseIdentifier = @"TagsCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    _photoCountLabel.text = [NSString stringWithFormat:@"%d photos selected.",TagsMenuMediator::GetNumberOfSelectedPhotos()];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillDisappear:(BOOL)animated
{
    TagsMenuMediator::OnClose();
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return TagsMenuMediator::GetNumberOfTags();
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TagsMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:CellReuseIdentifier forIndexPath:indexPath];
    Tag *tag = TagsMenuMediator::GetTagAtIndex((int)indexPath.item);
    [cell SetLabel: [NSString stringWithUTF8String:tag->GetName().c_str()]];
    [cell SetPhotoCount:TagsMenuMediator::GetSelectedPhotoCountWithTag(tag)];
    cell.photoTag = tag;
    cell.deleteButton.tag = indexPath.item;
    [cell.deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

-(void)deleteButtonClicked:(UIButton*)sender
{
    Tag *tag = TagsMenuMediator::GetTagAtIndex((int)sender.tag);
    int count = tag->GetTaggedPics().Count();

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete tag?" message:[NSString stringWithFormat:@"%d photos using tag %s",count,tag->GetName().c_str()] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                      {
                          TagsMenuMediator::DeleteTag(tag);
                          [alert dismissViewControllerAnimated:YES completion:nil];
                          [self.tableView reloadData];
                      }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                      {
                          [alert dismissViewControllerAnimated:YES completion:nil];
                      }]];
    
    [self presentViewController:alert animated:YES completion:nil];

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TagsMenuCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    int curCount =TagsMenuMediator::GetSelectedPhotoCountWithTag(cell.photoTag);
    if ( curCount < TagsMenuMediator::GetNumberOfSelectedPhotos() )
    {
        TagsMenuMediator::TagAllSelectedPics(cell.photoTag);
    }
    else
        TagsMenuMediator::UnTagAllSelectedPics(cell.photoTag);
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];

}


- (IBAction)handleAddButtonPressed:(id)sender{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add New Tag" message:@"Enter the name of your new tag:" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
        {
            bool added = TagsMenuMediator::AttemptAddTag ([alert.textFields.firstObject.text UTF8String]);
            // todo show failure
            [alert dismissViewControllerAnimated:YES completion:nil];
            [self.tableView reloadData];
        }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                      {
                          [alert dismissViewControllerAnimated:YES completion:nil];
                      }]];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Tag";
    }];
    [self presentViewController:alert animated:YES completion:nil];
    
}
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
