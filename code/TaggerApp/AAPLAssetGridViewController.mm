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
    scrollView.backgroundColor =[UIColor colorWithRed:0 green:122.0/255.0 blue:0.26 alpha:1.0];
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


UIScrollView* _tagScrollView;
XList<UIButton*> _buttonList;
XList< Tag*> _buttonTagList;
UIColor *tagButtonBackground = [UIColor colorWithRed:0 green:122.0/255.0 blue:1.0 alpha:1.0];
UIColor *tagButtonBackgroundSelected = [UIColor colorWithRed:.5 green:222.0/255.0 blue:1.0 alpha:1.0];
UIColor *tagButtonBorderColor =[UIColor colorWithRed:0 green:92.0/255.0 blue:0.8 alpha:1.0];
-(void)tagButtonClicked:(id) sender{
    UIButton *button =(UIButton*)sender;
    Tag * tag= _buttonTagList.Get((int)button.tag);
    GridViewController::OnTagClicked(tag,IsInSelectMode);
    SetTagButtonState(tag, button);
    [self reloadPhotos];
    
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
        xoffset += width+padX;

        [button setTitle:name forState:UIControlStateNormal];
        SetTagButtonState( t,button);
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.layer.cornerRadius = 10;
        button.layer.borderWidth = 1;
        button.layer.borderColor = tagButtonBorderColor.CGColor;
        [_tagScrollView addSubview:button];
        button.tag = _buttonTagList.Count();
        _buttonList.Add(button);
        _buttonTagList.Add(t);
        
    }
    CGSize sz = _tagScrollView.contentSize;
    _tagScrollView.contentSize = CGSizeMake( xoffset, sz.height);
    
}

void SetTagButtonState( Tag *tag, UIButton* button){
    button.backgroundColor = tagButtonBackground;
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
								contentMode:PHImageContentModeAspectFill
									options:nil
							  resultHandler:^(UIImage *result, NSDictionary *info) {
        // Set the cell's thumbnail image if it's still showing the same asset.
        if ([cell.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
            cell.thumbnailImage = result;
        }
    }];
    
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

@end


