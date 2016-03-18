//
//  FilterMenuTableViewController.m
//  Tagger
//
//  Created by Andy Kwiatkowski on 2016-02-29.
//
//

#include"Tag.h"
#import "FilterMenuTableViewController.h"
#import "TagsMenuCell.h"

@interface FilterMenuTableViewController ()
@property (nonatomic, strong) IBOutlet UILabel *selectedPhotosCountLabel;
@end

namespace FilterMenuMediator{
    int GetNumberOfTags();
    Tag *GetTagAtIndex( int index );
    bool IsTagSelected( Tag *tag );
    bool OnTagClicked( Tag *tag);
    int GetNumSelectedPhotos();
}

@implementation FilterMenuTableViewController
static NSString * const CellReuseIdentifier = @"TagsCell";


-(void)updateSelectedPhotos
{
    _selectedPhotosCountLabel.text = [NSString stringWithFormat:@"%d photos selected.",FilterMenuMediator::GetNumSelectedPhotos()];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateSelectedPhotos];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return FilterMenuMediator::GetNumberOfTags();
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TagsMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:CellReuseIdentifier forIndexPath:indexPath];
    Tag *tag = FilterMenuMediator::GetTagAtIndex((int)indexPath.item);
    [cell SetLabel: [NSString stringWithFormat:@"%s %s",tag->GetName().c_str(),FilterMenuMediator::IsTagSelected(tag)?"selected":""]];
    [cell SetPhotoCount:tag->GetTaggedPics().Count()];
    cell.photoTag = tag;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TagsMenuCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    FilterMenuMediator::OnTagClicked(cell.photoTag);
    [self updateSelectedPhotos];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
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
