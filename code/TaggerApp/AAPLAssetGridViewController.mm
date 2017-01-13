/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A view controller displaying a grid of assets.
 */
#define SHOW_KEYBOARD_TAG 0
#import "AAPLAssetGridViewController.h"

#import "AAPLGridViewCell.h"
#import "AAPLAssetViewController.h"
#import "NSIndexSet+Convenience.h"
#import "UICollectionView+Convenience.h"

#include<PhotosUI/PhotosUI.h>
#include"CustomTypes.h"
#include"XList.h"
#include"XString.h"
#include"Connector.hpp"

@interface AAPLAssetGridViewController () <PHPhotoLibraryChangeObserver>
@property (nonatomic, strong) IBOutlet UIBarButtonItem *addButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *selectButton;


@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property CGRect previousPreheatRect;
@end


@implementation AAPLAssetGridViewController

static NSString * const CellReuseIdentifier = @"Cell";
static CGSize AssetGridThumbnailSize;
static bool IsInSelectMode = false;

- (void)awakeFromNib {
    
    
}

const float brightness = 0.75;
UIColor *tagColors[]={
    [UIColor colorWithHue:0 saturation:1.0 brightness:brightness alpha:1.0],
    [UIColor colorWithHue:55/360.0 saturation:1.0 brightness:brightness alpha:1.0],
 [UIColor colorWithHue:93.0 / 360 saturation:1.0 brightness:brightness alpha:1.0],
 [UIColor colorWithHue:240.0 / 360 saturation:1.0 brightness:brightness alpha:1.0],
    [UIColor colorWithHue:172 / 360.0 saturation:1.0 brightness:brightness alpha:1.0],
      [UIColor colorWithHue:282 / 360.0 saturation:1.0 brightness:brightness alpha:1.0],
      [UIColor colorWithHue:23 / 360.0 saturation:1.0 brightness:brightness alpha:1.0],
    
    };

NSMutableDictionary *tagColorMap=[[NSMutableDictionary alloc] init];

void shadowAdd(UIButton *b );

PHFetchResult *FetchPhotos()
{
    // load all photos by default
    // Create a PHFetchResult object for each section in the table view.
    PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init];
    allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    PHFetchResult *allPhotos ;
    XList<const XString*> list;
    if ( !GridViewController::GetLocalIdentifiersToLoad(list))
        allPhotos= [PHAsset fetchAssetsWithOptions:allPhotosOptions];
    else{
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for( int i=0; i < list.Count(); i++ )
        {
            NSString *str = [NSString stringWithCString:list.Get(i)->c_str() encoding:NSASCIIStringEncoding];
            [array addObject:str];
        }
        allPhotos = [ PHAsset fetchAssetsWithLocalIdentifiers:array options:allPhotosOptions];
    }
    return allPhotos;

}

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

-(void) reloadPhotos{
    self.assetsFetchResults = FetchPhotos();
    [self.collectionView reloadData];
    
}
- (void)viewWillAppear:(BOOL)animated {
    

    // Determine the size of the thumbnails to request from the PHCachingImageManager
    CGFloat scale = [UIScreen mainScreen].scale ;
    int frameWidth = self.view.frame.size.width;
    int frameHeight = self.view.frame.size.height;
    int cellWidth = ((frameWidth<frameHeight)?frameWidth:frameHeight)*0.249;
    ((UICollectionViewFlowLayout *) self.collectionViewLayout).itemSize = CGSizeMake(cellWidth, cellWidth);
	CGSize cellSize = ((UICollectionViewFlowLayout *)self.collectionViewLayout).itemSize;
	AssetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
    
   
    
    // Add button to the navigation bar if the asset collection supports adding content.
    /*if (!self.assetCollection || [self.assetCollection canPerformEditOperation:PHCollectionEditOperationAddContent]) {
        self.navigationItem.rightBarButtonItem = self.addButton;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }*/
}
bool first = true;
- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.imageManager = [[PHCachingImageManager alloc] init];
    [self resetCachedAssets];
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];

     [self reloadPhotos];
    [super viewDidAppear:animated];
    
    // Begin caching assets in and around collection view's visible rect.
    [self updateCachedAssets];
    
    // add bottom tag selection stuff
    if ( !first )
        return;
    first = false;
    // parent view container
    CGFloat selfWidth = self.view.frame.size.width;
    CGFloat newWidth = selfWidth-80;
    CGRect rect = CGRectMake(newWidth/2-100/2,1,100,30);
    // button tag scrollview Container
    CGFloat scrollHt = 35;
    rect = CGRectMake(0,0,newWidth, scrollHt);
    UIScrollView* scrollView=[[UIScrollView alloc] initWithFrame:rect] ;
    //scrollView.backgroundColor =[UIColor colorWithRed:0 green:122.0/255.0 blue:0.26 alpha:1.0];
    scrollView.contentSize = CGSizeMake(newWidth*2,scrollHt);
      _tagScrollView = scrollView;
  
    // add the scrollview to the toolbar
    UIBarButtonItem *newButton = [[UIBarButtonItem alloc] initWithCustomView:scrollView];
    NSMutableArray *items = [[NSMutableArray alloc] init];
    [items addObject:newButton];
       for ( id obj in self.toolbarItems){
        [items addObject:obj];
    }
    [self setToolbarItems:items];

    [self updateTagList:""];
}


static UIScrollView* _tagScrollView;
static XList<UIButton*> _buttonList;
static XList<UIButton*> _buttonBadgeList;
static XList< Tag*> _buttonTagList;

UIColor *tagButtonBackground = [UIColor colorWithRed:0 green:122.0/255.0 blue:1.0 alpha:1.0];
UIColor *tagButtonBackgroundSelected = [UIColor colorWithRed:.5 green:222.0/255.0 blue:1.0 alpha:1.0];
UIColor *tagButtonBorderColor =[UIColor colorWithRed:0 green:92.0/255.0 blue:0.8 alpha:1.0];
-(void)tagButtonClicked:(id) sender{
    UIButton *button =(UIButton*)sender;
    Tag * tag= _buttonTagList.Get((int)button.tag);
    GridViewController::OnTagClicked(tag,IsInSelectMode,_buttonBadgeList.Get((int)button.tag).tag==0);
    SetTagButtonState(tag, button);
    UIButton *badge = _buttonBadgeList.Get((int)button.tag);
    badge.tag = !badge.tag;
    if ( !IsInSelectMode){
        [badge setTitle:@"999" forState:UIControlStateNormal] ;
    }
    else
    if ( badge.tag ){ // untag
        [badge setTitle:@"-" forState:UIControlStateNormal] ;
    }
    else{
        [badge setTitle:@"+" forState:UIControlStateNormal] ;
    }
    
    if ( !IsInSelectMode){
        [self reloadPhotos];
    }else{
        for(UICollectionViewCell *cell in self.collectionView.visibleCells){
            [self updateTagColorsForCell:(AAPLGridViewCell*)cell];
            //add animation to cell here
        }
    }
    
}
-(void)updateTagList:(const char*)startsWith {
    
    XList< Tag*> tagList;
    GridViewController::OnTextFilterChange(startsWith, tagList);
    // clear buttons
    foreach(UIButton*, b, _buttonList){
        [b removeFromSuperview];
    }
    _buttonList.Clear();
    _buttonTagList.Clear();
    _buttonBadgeList.Clear();
    
    // add button for each tag
    int xoffset =0;
    int yoffset = 0;
    int padX = 4;
    int innerPadX = 12;
    
    foreach (  Tag*, t, tagList ){
        NSString *name = [NSString stringWithUTF8String:t->GetName().c_str()];
        UIButton* button =[UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button addTarget:self action:@selector(tagButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        NSDictionary *attributes = @{NSFontAttributeName:button.titleLabel.font};
        CGSize stringSize = [name sizeWithAttributes:attributes];
        int width = stringSize.width + innerPadX;
        const int height = 30;

        button.frame = CGRectMake(10+xoffset,yoffset,width,height);
        

        [button setTitle:name forState:UIControlStateNormal];
         button.tag = _buttonTagList.Count();
        t->ID = _buttonTagList.Count();
        const int maxColors = sizeof(tagColors)/ sizeof(UIColor*);
        tagColorMap[[NSNumber numberWithInt:t->ID]] = tagColors[t->ID % maxColors];
        SetTagButtonState( t,button);
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.layer.cornerRadius = 10;
        button.layer.borderWidth = 1;
        button.layer.borderColor = tagButtonBorderColor.CGColor;
        [_tagScrollView addSubview:button];
       
        UIGestureRecognizer *longPressRecognizer= [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressTag:)];
        [button addGestureRecognizer:longPressRecognizer];
        shadowAdd(button);
        
        // add a badge too, don't delete because we need the stupid tag for state control (TODO: FIX THIS), TODO: TECH DEBT
        UIButton* badge= [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [badge setTitle:@"+" forState:UIControlStateNormal];
        badge.frame = CGRectMake(10+xoffset+width-8, yoffset-1, 15,15);
        badge.backgroundColor =[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
        badge.layer.cornerRadius = 7;
        badge.layer.borderWidth = 1;
        badge.layer.borderColor = tagButtonBorderColor.CGColor;
        //[button addTarget:self action:@selector(tagButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        //[_tagScrollView addSubview:badge];
        
        
        xoffset += width+padX;
        
        _buttonList.Add(button);
        _buttonTagList.Add(t);
        _buttonBadgeList.Add(badge);
        
    }
    CGSize sz = _tagScrollView.contentSize;
    _tagScrollView.contentSize = CGSizeMake( xoffset, sz.height);
    
}

void SetTagButtonState( Tag *tag, UIButton* button){
    button.backgroundColor = tagColorMap[[NSNumber numberWithInt:tag->ID]];
    if ( GridViewController::IsTagSelected(tag)){
        button.backgroundColor = tagButtonBackgroundSelected;
    }

}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ( IsInSelectMode && [identifier isEqual:@"singlePic"] )
        return NO;
    return YES;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Configure the destination AAPLAssetViewController.
    if ([segue.destinationViewController isKindOfClass:[AAPLAssetViewController class]]) {
        AAPLAssetViewController *assetViewController = segue.destinationViewController;
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
        assetViewController.asset = self.assetsFetchResults[indexPath.item];
        assetViewController.assetCollection = self.assetCollection;
        assetViewController.assetsFetchResults = self.assetsFetchResults;
        assetViewController.assetFetchIndex = indexPath.item;
    }
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    // Check if there are changes to the assets we are showing.
    PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.assetsFetchResults];
    if (collectionChanges == nil) {
        return;
    }
    
    /*
        Change notifications may be made on a background queue. Re-dispatch to the
        main queue before acting on the change as we'll be updating the UI.
     */
    dispatch_async(dispatch_get_main_queue(), ^{
        // Get the new fetch result.
        self.assetsFetchResults = [collectionChanges fetchResultAfterChanges];
        
        UICollectionView *collectionView = self.collectionView;
        
        if (![collectionChanges hasIncrementalChanges] || [collectionChanges hasMoves]) {
            // Reload the collection view if the incremental diffs are not available
            [collectionView reloadData];
            
        } else {
            /*
                Tell the collection view to animate insertions and deletions if we
                have incremental diffs.
             */
            [collectionView performBatchUpdates:^{
                NSIndexSet *removedIndexes = [collectionChanges removedIndexes];
                if ([removedIndexes count] > 0) {
                    [collectionView deleteItemsAtIndexPaths:[removedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                }
                
                NSIndexSet *insertedIndexes = [collectionChanges insertedIndexes];
                if ([insertedIndexes count] > 0) {
                    [collectionView insertItemsAtIndexPaths:[insertedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                }
                
                NSIndexSet *changedIndexes = [collectionChanges changedIndexes];
                if ([changedIndexes count] > 0) {
                    [collectionView reloadItemsAtIndexPaths:[changedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                }
            } completion:NULL];
        }
        
        [self resetCachedAssets];
    });
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assetsFetchResults.count;
}

- (void ) updateTagColorsForCell: (AAPLGridViewCell*) cell{
    XList<UIView*> *colorList  = cell.tagColorViews;
    const float width = cell.frame.size.width *0.08;
    const float space = width/2;
    if ( colorList == NULL){
        colorList = new XList<UIView*>();
        for ( int i= 0; i < 5; i++ ){

            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(cell.frame.size.width-space*i - width*i -space-width,cell.frame.size.height - space - width ,width,width)];
            [cell addSubview:view];
            colorList->Add(view);
        }
        
        cell.tagColorViews = colorList;
    }
    
    
    XList<Tag*> tags;
    SinglePicViewMediator::GetTagsWithPic(cell.assetHash, &tags);
    for( int i=0; i < colorList->Count(); i++ ){
        Tag* tag = NULL;
        if ( i < tags.Count())
        {
            tag = tags.Get(i);
        }
        
        UIView *view = colorList->Get(i);
        if ( tag == NULL ){
            view.hidden =true;
        }
        else{
            view.hidden = false;
            view.backgroundColor = tagColorMap[[NSNumber numberWithInt:tag->ID]];
        }
    }

}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *asset = self.assetsFetchResults[indexPath.item];

    // Dequeue an AAPLGridViewCell.
    AAPLGridViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellReuseIdentifier forIndexPath:indexPath];
    cell.representedAssetIdentifier = asset.localIdentifier;
    cell.assetHash = asset.hash;
    if ( GridViewController::IsAssetSelected(cell.assetHash))
        [cell showCheckmark];
    else
        [cell hideCheckmark];
    
    // Add a badge to the cell if the PHAsset represents a Live Photo.
    if (asset.mediaSubtypes & PHAssetMediaSubtypePhotoLive) {
        // Add Badge Image to the cell to denote that the asset is a Live Photo.
        UIImage *badge = [PHLivePhotoView livePhotoBadgeImageWithOptions:PHLivePhotoBadgeOptionsOverContent];
        cell.livePhotoBadgeImage = badge;
        
    }
    
    // Request an image for the asset from the PHCachingImageManager.
    [self.imageManager requestImageForAsset:asset
								 targetSize:AssetGridThumbnailSize
								contentMode:PHImageContentModeAspectFit
									options:nil
							  resultHandler:^(UIImage *result, NSDictionary *info) {
        // Set the cell's thumbnail image if it's still showing the same asset.
        if ([cell.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
            cell.thumbnailImage = result;
        }
    }];
    
    [self updateTagColorsForCell:cell];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    AAPLGridViewCell *cell =(AAPLGridViewCell*) [collectionView cellForItemAtIndexPath:indexPath];
    if ( IsInSelectMode ){
        if ( !GridViewController::IsAssetSelected( cell.assetHash) )
        {
            GridViewController::SelectAsset( cell.assetHash ,[cell.representedAssetIdentifier UTF8String]);
            [cell showCheckmark];
        }
        else{
            GridViewController::DeSelectAsset( cell.assetHash );
            [cell hideCheckmark];
        }
    }
}
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Update cached assets for the new visible area.
    [self updateCachedAssets];
}

#pragma mark - Asset Caching

- (void)resetCachedAssets {
    [self.imageManager stopCachingImagesForAllAssets];
    self.previousPreheatRect = CGRectZero;
}

- (void)updateCachedAssets {
    BOOL isViewVisible = [self isViewLoaded] && [[self view] window] != nil;
    if (!isViewVisible) { return; }
    
    // The preheat window is twice the height of the visible rect.
    CGRect preheatRect = self.collectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));
    
    /*
        Check if the collection view is showing an area that is significantly
        different to the last preheated area.
     */
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    if (delta > CGRectGetHeight(self.collectionView.bounds) / 3.0f) {
        
        // Compute the assets to start caching and to stop caching.
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [self computeDifferenceBetweenRect:self.previousPreheatRect andRect:preheatRect removedHandler:^(CGRect removedRect) {
            NSArray *indexPaths = [self.collectionView aapl_indexPathsForElementsInRect:removedRect];
            [removedIndexPaths addObjectsFromArray:indexPaths];
        } addedHandler:^(CGRect addedRect) {
            NSArray *indexPaths = [self.collectionView aapl_indexPathsForElementsInRect:addedRect];
            [addedIndexPaths addObjectsFromArray:indexPaths];
        }];
        
        NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
        NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
        
        // Update the assets the PHCachingImageManager is caching.
        [self.imageManager startCachingImagesForAssets:assetsToStartCaching
											targetSize:AssetGridThumbnailSize
										   contentMode:PHImageContentModeAspectFill
											   options:nil];
        [self.imageManager stopCachingImagesForAssets:assetsToStopCaching
										   targetSize:AssetGridThumbnailSize
										  contentMode:PHImageContentModeAspectFill
											  options:nil];

        // Store the preheat rect to compare against in the future.
        self.previousPreheatRect = preheatRect;
    }
}

- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler {
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths {
    if (indexPaths.count == 0) { return nil; }
    
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        PHAsset *asset = self.assetsFetchResults[indexPath.item];
        [assets addObject:asset];
    }
    
    return assets;
}

#pragma mark - Actions

- (IBAction)handleTagButtonPressed:(id)sender{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add New Tag" message:@"Enter the name of your new tag:" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                      {
                          bool added = TagsMenuMediator::AttemptAddTag ([alert.textFields.firstObject.text UTF8String]);
                          // todo show failure
                          [alert dismissViewControllerAnimated:YES completion:nil];
                          [self updateTagList:""];
                          
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

- (IBAction)showDeleteTagPopup:(Tag*)tag{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Edit Tag" message:@"Edit tag name:" preferredStyle:UIAlertControllerStyleAlert];
    // save/rename-------
    [alert addAction:[UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                      {
                          GridViewController::RenameTag(tag,[alert.textFields.firstObject.text UTF8String]);
                          [self updateTagList:""];
                      }]];
    
    // delete ----------
    [alert addAction:[UIAlertAction actionWithTitle:@"Delete Tag" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                      {
                          UIAlertController *confirmPopup =[UIAlertController alertControllerWithTitle:@"Delete Tag" message:@"Delete tag permanently?" preferredStyle:UIAlertControllerStyleAlert];
                          [confirmPopup addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                            {
                                                GridViewController::DeleteTag(tag);
                                                [self updateTagList:""];
                                                 [confirmPopup dismissViewControllerAnimated:YES completion:nil];
                                               
                                            }]];
                          [confirmPopup addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                            {
                                                [confirmPopup dismissViewControllerAnimated:YES completion:nil];
                                            }]];
                          [self presentViewController:confirmPopup animated:YES completion:nil];

                      }]];
    
    // cancel --------
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                      {
                          [alert dismissViewControllerAnimated:YES completion:nil];
                      }]];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text =[NSString stringWithUTF8String:tag->GetName().c_str()];
    }];
    [self presentViewController:alert animated:YES completion:nil];
    
}


- (IBAction)handleSelectButtonItem:(id)sender{
    if ( !IsInSelectMode )
    {
        IsInSelectMode = true;
        _selectButton.title = @"Cancel";
    }
    else
    {
        IsInSelectMode = false;
        _selectButton.title = @"Select";
        GridViewController::OnExitSelectionMode();
        [self reloadPhotos];
    }

}
- (IBAction)handleAddButtonItem:(id)sender {
    // Create a random dummy image.
    CGRect rect = rand() % 2 == 0 ? CGRectMake(0, 0, 400, 300) : CGRectMake(0, 0, 300, 400);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 1.0f);
    [[UIColor colorWithHue:(float)(rand() % 100) / 100 saturation:1.0 brightness:1.0 alpha:1.0] setFill];
    UIRectFillUsingBlendMode(rect, kCGBlendModeNormal);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Add it to the photo library
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        
        if (self.assetCollection) {
            PHAssetCollectionChangeRequest *assetCollectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:self.assetCollection];
            [assetCollectionChangeRequest addAssets:@[[assetChangeRequest placeholderForCreatedAsset]]];
        }
    } completionHandler:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"Error creating asset: %@", error);
        }
    }];
}

-(void)longPressTag:(UILongPressGestureRecognizer *)gesture{
    if ( gesture.state == UIGestureRecognizerStateBegan ){
        UIView *button =gesture.view;
        Tag * tag= _buttonTagList.Get((int)button.tag);
        [self showDeleteTagPopup:tag];
    }
}

@end


