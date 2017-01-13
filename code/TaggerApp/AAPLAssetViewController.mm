/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A view controller displaying an asset full screen.
 */

#import "AAPLAssetViewController.h"
#include "CIImage+Convenience.h"

#include<PhotosUI/PhotosUI.h>

#include"Xlist.h"
#include"Connector.hpp"
#include"CustomTypes.h"

@interface AAPLAssetViewController () <PHPhotoLibraryChangeObserver, PHLivePhotoViewDelegate>

@property (nonatomic, weak) IBOutlet PHLivePhotoView *livePhotoView;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIImageView *imageViewLeft;
@property (nonatomic, weak) IBOutlet UIImageView *imageViewRight;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic, weak) IBOutlet UIProgressView *progressView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *playButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *space;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *trashButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imageRightWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imageLeftWidthConstraint;

@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, assign) CGSize lastTargetSize;
@property (nonatomic, assign) BOOL playingHint;
@end

@implementation AAPLAssetViewController
{
    UIScrollView* _tagScrollView;
    XList<UIButton*> _buttonList;
    XList< Tag*> _buttonTagList;
    XList<Tag*> currentPicTags;
   
    bool firstFrame ;
}

extern UIColor *tagButtonBackground ;
extern UIColor *tagButtonBackgroundSelected;
extern UIColor *tagButtonBorderColor;
extern NSMutableDictionary *tagColorMap;

static NSString * const AdjustmentFormatIdentifier = @"com.example.apple-samplecode.SamplePhotosApp";

#pragma mark - View Lifecycle Methods.
static XList<UIButton*> _animatedButtonList;
- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)viewDidLoad {
    firstFrame = true;
    [super viewDidLoad];
    self.livePhotoView.delegate = self;
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

-(void) reloadImage {
    
    
    // Set the appropriate toolbarItems based on the mediaType of the asset.
    if (self.asset.mediaType == PHAssetMediaTypeVideo) {
        [self showPlaybackToolbar];
    } else {
        [self showStaticToolbar];
    }
    
    // Enable the edit button if the asset can be edited.
    BOOL isEditable = ([self.asset canPerformEditOperation:PHAssetEditOperationProperties] || [self.asset canPerformEditOperation:PHAssetEditOperationContent]);
    self.editButton.enabled = isEditable;
    
    // Enable the trash button if the asset can be deleted.
    BOOL isTrashable = NO;
    if (self.assetCollection) {
        isTrashable = [self.assetCollection canPerformEditOperation:PHCollectionEditOperationRemoveContent];
    } else {
        isTrashable = [self.asset canPerformEditOperation:PHAssetEditOperationDelete];
    }
    self.trashButton.enabled = isTrashable;
    
    [self updateImage];
    currentPicTags.Clear();
    SinglePicViewMediator::GetTagsWithPic(self.asset.hash,&currentPicTags);
    [self addTagButtons];
    [self.view layoutIfNeeded];
   
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    [self reloadImage];
   
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
    [self.view addGestureRecognizer:panRecognizer];
    
    _imageRightWidthConstraint.constant = self.view.bounds.size.width;
    _imageLeftWidthConstraint.constant = self.view.bounds.size.width;
    
    
}


void shadowAdd(UIButton *b ){
    b.layer.shadowColor = [UIColor blackColor].CGColor;
    b.layer.shadowOpacity = 0.8;
    b.layer.shadowRadius = 2;
    b.layer.shadowOffset = CGSizeMake(1.2f, 1.2f);
}
-(void)addTagButtons{
    
    // add bottom tag selection scrollview
    if ( firstFrame ){
       
       // firstFrame = false;
        // parent view container
        CGFloat selfWidth = self.view.frame.size.width;
        CGFloat newWidth = selfWidth-80;
        CGRect rect = CGRectMake(newWidth/2-100/2,1,100,30);
        // button tag scrollview Container
        CGFloat scrollHt = 35;
        rect = CGRectMake(0,0,newWidth, scrollHt);
        UIScrollView* scrollView=[[UIScrollView alloc] initWithFrame:rect] ;
      //  scrollView.backgroundColor =[UIColor colorWithRed:0 green:122.0/255.0 blue:0.26 alpha:1.0];
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
    }
    
    XList< Tag*> tagList;
    SinglePicViewMediator::GetAllTags( &tagList );
    
    //SinglePicViewMediator::GetTagsWithPic(self.asset.hash,&tagList );
    // clear buttons
    foreach(UIButton*, b, _buttonList){
        [b removeFromSuperview];
    }
    
    foreach ( UIButton *,b, _animatedButtonList){
        [b removeFromSuperview];
    }
    _buttonList.Clear();
    _buttonTagList.Clear();
    _animatedButtonList.Clear();
    
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
        
        
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.layer.cornerRadius = 10;
        button.layer.borderWidth = 1;
        button.layer.borderColor = tagButtonBorderColor.CGColor;
        
        [_tagScrollView addSubview:button];
        button.tag = _buttonTagList.Count();
        shadowAdd(button);
        
        _buttonList.Add(button);
        _buttonTagList.Add(t);
        [self updateTagButtonState:t Button:button];
        
        UIButton* buttonA =[UIButton buttonWithType:UIButtonTypeRoundedRect];
        [buttonA addTarget:self action:@selector(tagButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        buttonA.frame = CGRectMake(0,0,width,height);
        buttonA.hidden = true;
        
        [buttonA setTitle:name forState:UIControlStateNormal];
        
        
        [buttonA setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        buttonA.layer.cornerRadius = 10;
        buttonA.layer.borderWidth = 1;
        buttonA.layer.borderColor = tagButtonBorderColor.CGColor;
        buttonA.backgroundColor =tagColorMap[[NSNumber numberWithInt:t->ID]];;
        
        [self.view addSubview:buttonA];
        buttonA.tag = button.tag;
        shadowAdd(buttonA);
        _animatedButtonList.Add(buttonA);
    
    }
    CGSize sz = _tagScrollView.contentSize;
    _tagScrollView.contentSize = CGSizeMake( xoffset, sz.height);
        [self setAnimatedButtonPositions];

}

-(void)setAnimatedButtonPositions{
    float y = 100;
    float x = 50;
    foreach( UIButton*, b , _animatedButtonList ){
        Tag* t = _buttonTagList.Get((int)b.tag);
        if ( currentPicTags.Contains(t)){
            b.center = CGPointMake(x,y);
            x+= b.frame.size.width + 4;
            [b setHidden:false];

        }
        else{
             b.center = CGPointMake(50,1550);
           // [b setHidden:true];
        }
    }

}

- (void)viewWillDisappear:(BOOL)animated {
    [UIView setAnimationsEnabled: NO];
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.type = kCATransitionFade;
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
}

- (void)viewDidDisappear:(BOOL)animated {
    [UIView setAnimationsEnabled: YES];
}

-(void)tagButtonClicked:(id) sender{
    UIButton *button =(UIButton*)sender;
    Tag * tag= _buttonTagList.Get((int)button.tag);
    if ( !currentPicTags.Contains(tag))
    {
        currentPicTags.Add(tag);
        SinglePicViewMediator::TagPic( self.asset.hash, tag );
      
        [UIView animateWithDuration:0.38 animations:^{
            [self setAnimatedButtonPositions];
        }];
    }
    else{
        currentPicTags.Remove(tag);
        SinglePicViewMediator::UnTagPic(self.asset.hash, tag );
         [UIView animateWithDuration:0.38 animations:^{
        [self setAnimatedButtonPositions];
         }];
    }
    
    [self updateTagButtonState:tag Button:_buttonList.Get((int)button.tag)];
     
}
-(void)updateTagButtonState:(Tag*)tag Button:(UIButton*)button{
    
   if ( currentPicTags.Contains(tag)){
        button.backgroundColor = tagButtonBackgroundSelected;
    }
    else
        button.backgroundColor = button.backgroundColor = tagColorMap[[NSNumber numberWithInt:tag->ID]];;
    
}

float firstX,firstY;
-(void)onPan:(UIPanGestureRecognizer*)recognizer{
    if ( [recognizer state]== UIGestureRecognizerStateBegan){
        firstX = [[recognizer view] center].x;
        firstY = [[recognizer view] center].y;
    }
    CGPoint translatedPoint = [recognizer translationInView:self.view];
    CGPoint newCenter = CGPointMake(firstX+translatedPoint.x, firstY);
    const float swapThreshold = 0.35f;
    [[recognizer view] setCenter:newCenter];
    if ( [recognizer state]  == UIGestureRecognizerStateEnded){
        if ( translatedPoint.x > self.view.bounds.size.width* swapThreshold ){
            [UIView animateWithDuration:0.25 animations:^{
                [[recognizer view] setCenter:CGPointMake(firstX + self.view.bounds.size.width,firstY)];
            }
             completion:^(BOOL finished) {
                 self.assetFetchIndex = self.assetFetchIndex==0?(self.assetsFetchResults.count-1):self.assetFetchIndex-1;
                  self.asset = self.assetsFetchResults[self.assetFetchIndex];
                 self.imageView.image = self.imageViewLeft.image;
                 [self reloadImage];
                 [[recognizer view] setCenter:CGPointMake(firstX, firstY)];
             }
             ];
        }else
        if ( translatedPoint.x <-self.view.bounds.size.width*swapThreshold ){
            [UIView animateWithDuration:0.25 animations:^{
                [[recognizer view] setCenter:CGPointMake(firstX - self.view.bounds.size.width,firstY)];
            }
                             completion:^(BOOL finished) {
                                 self.assetFetchIndex = (self.assetFetchIndex+1)%self.assetsFetchResults.count;
                                 self.asset = self.assetsFetchResults[self.assetFetchIndex];
                                 self.imageView.image = self.imageViewRight.image;
                                 [self reloadImage];
                                 [[recognizer view] setCenter:CGPointMake(firstX, firstY)];
                             }
             ];
        }
        else{
            [UIView animateWithDuration:0.25 animations:^{
                      [[recognizer view] setCenter:CGPointMake(firstX,firstY)];
            }];
        }
    }
}

//http://www.appcoda.com/ios-gesture-recognizers/

-(void)slideToRightWithGestureRecognizer:(UISwipeGestureRecognizer *)gestureRecognizer{
    int length = self.assetsFetchResults.count;
    self.assetFetchIndex++;
    self.assetFetchIndex %= length;
    self.asset = self.assetsFetchResults[self.assetFetchIndex];
    [self reloadImage];
    
}

-(void)slideToLeftWithGestureRecognizer:(UISwipeGestureRecognizer *)gestureRecognizer{
    int length = self.assetsFetchResults.count;
    self.assetFetchIndex--;
    if ( self.assetFetchIndex < 0 )
        self.assetFetchIndex = length -1;
    self.asset = self.assetsFetchResults[self.assetFetchIndex];
    [self reloadImage];
}


#pragma mark - View & Toolbar setup methods.

- (void)showLivePhotoView {
    self.livePhotoView.hidden = NO;
    self.imageView.hidden = YES;
}

- (void)showStaticPhotoView {
    self.livePhotoView.hidden = YES;
    self.imageView.hidden = NO;
}

- (void)showPlaybackToolbar {
    self.toolbarItems = @[self.playButton, self.space, self.trashButton];
}

- (void)showStaticToolbar {
    self.toolbarItems = @[self.space, self.trashButton];
}

- (CGSize)targetSize {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize targetSize = CGSizeMake(CGRectGetWidth(self.imageView.bounds) * scale, CGRectGetHeight(self.imageView.bounds) * scale);
    return targetSize;
}

#pragma mark - ImageView/LivePhotoView Image Setting methods.

- (void)updateImage {
    self.lastTargetSize = [self targetSize];

    // Check the asset's `mediaSubtypes` to determine if this is a live photo or not.
    BOOL assetHasLivePhotoSubType = (self.asset.mediaSubtypes & PHAssetMediaSubtypePhotoLive);
    if (assetHasLivePhotoSubType) {
        [self updateLiveImage];
    }
    else {
        [self updateStaticImage];
    }
}

- (void)updateLiveImage {
    // Prepare the options to pass when fetching the live photo.
    PHLivePhotoRequestOptions *livePhotoOptions = [[PHLivePhotoRequestOptions alloc] init];
    livePhotoOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    livePhotoOptions.networkAccessAllowed = YES;
    livePhotoOptions.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        /*
            Progress callbacks may not be on the main thread. Since we're updating
            the UI, dispatch to the main queue.
         */
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressView.progress = progress;
        });
    };
    
    // Request the live photo for the asset from the default PHImageManager.
    [[PHImageManager defaultManager] requestLivePhotoForAsset:self.asset targetSize:[self targetSize] contentMode:PHImageContentModeAspectFit options:livePhotoOptions resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
        // Hide the progress view now the request has completed.
        self.progressView.hidden = YES;
        
        // Check if the request was successful.
        if (!livePhoto) {
            return;
        }
        
        NSLog (@"Got a live photo");

        // Show the PHLivePhotoView and use it to display the requested image.
        [self showLivePhotoView];
        self.livePhotoView.livePhoto = livePhoto;
        
        if (![info[PHImageResultIsDegradedKey] boolValue] && !self.playingHint) {
            // Playback a short section of the live photo; similar to the Photos share sheet.
            NSLog (@"playing hint...");
            self.playingHint = YES;
            [self.livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleHint];
        }
        
        // Update the toolbar to show the correct items for a live photo.
        [self showPlaybackToolbar];
    }];
}


- (void)updateStaticImage {
    // Prepare the options to pass when fetching the live photo.
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.networkAccessAllowed = YES;
    options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        /*
            Progress callbacks may not be on the main thread. Since we're updating
            the UI, dispatch to the main queue.
         */
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressView.progress = progress;
        });
    };
    
    
    [[PHImageManager defaultManager] requestImageForAsset:self.asset targetSize:[self targetSize] contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        // Hide the progress view now the request has completed.
        self.progressView.hidden = YES;
        
        // Check if the request was successful.
        if (!result) {
            return;
        }
        
        // Show the UIImageView and use it to display the requested image.
        [self showStaticPhotoView];
        self.imageView.image = result;
    }];
    
    PHAsset *asset = self.assetsFetchResults[(self.assetFetchIndex+1)%self.assetsFetchResults.count];
    
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:[self targetSize] contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        // Check if the request was successful.
        if (!result) {
            return;
        }
        
        self.imageViewRight.image = result;
    }];
    
    asset = self.assetsFetchResults[self.assetFetchIndex==0?(self.assetsFetchResults.count-1):(self.assetFetchIndex-1)];
    
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:[self targetSize] contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        // Check if the request was successful.
        if (!result) {
            return;
        }
        
        self.imageViewLeft.image = result;
    }];

    
    
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    // Call might come on any background queue. Re-dispatch to the main queue to handle it.
    dispatch_async(dispatch_get_main_queue(), ^{
        // Check if there are changes to the asset we're displaying.
        PHObjectChangeDetails *changeDetails = [changeInstance changeDetailsForObject:self.asset];
        if (changeDetails == nil) {
            return;
        }
        
        // Get the updated asset.
        self.asset = [changeDetails objectAfterChanges];
        
        // If the asset's content changed, update the image and stop any video playback.
        if ([changeDetails assetContentChanged]) {
            [self updateImage];
            
            [self.playerLayer removeFromSuperlayer];
            self.playerLayer = nil;
        }
    });
}

#pragma mark - Target Action Methods.

- (IBAction)handleEditButtonItem:(id)sender {
    // Use a UIAlertController to display the editing options to the user.
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    alertController.modalPresentationStyle = UIModalPresentationPopover;
    alertController.popoverPresentationController.barButtonItem = sender;
    alertController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    
    // Add an action to dismiss the UIAlertController.
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:NULL]];

    // If PHAsset supports edit operations, allow the user to toggle its favorite status.
    if ([self.asset canPerformEditOperation:PHAssetEditOperationProperties]) {
        NSString *favoriteActionTitle = !self.asset.favorite ? NSLocalizedString(@"Favorite", @"") : NSLocalizedString(@"Unfavorite", @"");
        
        [alertController addAction:[UIAlertAction actionWithTitle:favoriteActionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self toggleFavoriteState];
        }]];
    }
    
    // Only allow editing if the PHAsset supports edit operations and it is not a Live Photo.
    if ([self.asset canPerformEditOperation:PHAssetEditOperationContent] && !(self.asset.mediaSubtypes & PHAssetMediaSubtypePhotoLive)) {
        // Allow filters to be applied if the PHAsset is an image.
        if (self.asset.mediaType == PHAssetMediaTypeImage) {
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Sepia", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self applyFilterWithName:@"CISepiaTone"];
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Chrome", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self applyFilterWithName:@"CIPhotoEffectChrome"];
            }]];
        }
        
        // Add actions to revert any edits that have been made to the PHAsset.
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Revert", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self revertToOriginal];
        }]];
    }
    
    // Present the UIAlertController.
    [self presentViewController:alertController animated:YES completion:NULL];
}

- (IBAction)handleTrashButtonItem:(id)sender {
    void (^completionHandler)(BOOL, NSError *) = ^(BOOL success, NSError *error) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[self navigationController] popViewControllerAnimated:YES];
            });
        } else {
            NSLog(@"Error: %@", error);
        }
    };
    
    if (self.assetCollection) {
        // Remove asset from album
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetCollectionChangeRequest *changeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:self.assetCollection];
            [changeRequest removeAssets:@[self.asset]];
        } completionHandler:completionHandler];
        
    } else {
        // Delete asset from library
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetChangeRequest deleteAssets:@[self.asset]];
        } completionHandler:completionHandler];
        
    }
}

- (IBAction)handlePlayButtonItem:(id)sender {
    if (self.livePhotoView.livePhoto != nil) {
        // We're displaying a live photo, begin playing it.
        [self.livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
    } else if (self.playerLayer != nil) {
        // An AVPlayerLayer has already been created for this asset.
        [self.playerLayer.player play];
    }
    else {
        // Request an AVAsset for the PHAsset we're displaying.
        [[PHImageManager defaultManager] requestAVAssetForVideo:self.asset options:nil resultHandler:^(AVAsset *avAsset, AVAudioMix *audioMix, NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!self.playerLayer) {
                    CALayer *viewLayer = self.view.layer;
                    
                    // Create an AVPlayerItem for the AVAsset.
                    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:avAsset];
                    playerItem.audioMix = audioMix;
                    
                    // Create an AVPlayer with the AVPlayerItem.
                    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
                    
                    // Create an AVPlayerLayer with the AVPlayer.
                    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
                    
                    // Configure the AVPlayerLayer and add it to the view.
                    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
                    playerLayer.frame = CGRectMake(0, 0, viewLayer.bounds.size.width, viewLayer.bounds.size.height);
                    
                    [viewLayer addSublayer:playerLayer];
                    [player play];
                    
                    // Store a reference to the player layer we added to the view.
                    self.playerLayer = playerLayer;
                }
            });
        }];
    }
}

#pragma mark - PHLivePhotoViewDelegate Protocol Methods.

- (void)livePhotoView:(PHLivePhotoView *)livePhotoView willBeginPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle {
    NSLog(@"Will Beginning Playback of Live Photo...");
}

- (void)livePhotoView:(PHLivePhotoView *)livePhotoView didEndPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle {
    NSLog(@"Did End Playback of Live Photo...");
    self.playingHint = NO;
}

#pragma mark - Photo editing methods.

- (void)applyFilterWithName:(NSString *)filterName {
    // Prepare the options to pass when requesting to edit the image.
    PHContentEditingInputRequestOptions *options = [[PHContentEditingInputRequestOptions alloc] init];
    [options setCanHandleAdjustmentData:^BOOL(PHAdjustmentData *adjustmentData) {
        return [adjustmentData.formatIdentifier isEqualToString:AdjustmentFormatIdentifier] && [adjustmentData.formatVersion isEqualToString:@"1.0"];
    }];
    
    [self.asset requestContentEditingInputWithOptions:options completionHandler:^(PHContentEditingInput *contentEditingInput, NSDictionary *info) {
        // Create a CIImage from the full image representation.
        NSURL *url = [contentEditingInput fullSizeImageURL];
        int orientation = [contentEditingInput fullSizeImageOrientation];
        CIImage *inputImage = [CIImage imageWithContentsOfURL:url options:nil];
        inputImage = [inputImage imageByApplyingOrientation:orientation];

        // Create the filter to apply.
        CIFilter *filter = [CIFilter filterWithName:filterName];
        [filter setDefaults];
        [filter setValue:inputImage forKey:kCIInputImageKey];
        
        // Apply the filter.
        CIImage *outputImage = [filter outputImage];

        // Create a PHAdjustmentData object that describes the filter that was applied.
        PHAdjustmentData *adjustmentData = [[PHAdjustmentData alloc] initWithFormatIdentifier:AdjustmentFormatIdentifier formatVersion:@"1.0" data:[filterName dataUsingEncoding:NSUTF8StringEncoding]];
        
        /*
            Create a PHContentEditingOutput object and write a JPEG representation
            of the filtered object to the renderedContentURL.
         */
        PHContentEditingOutput *contentEditingOutput = [[PHContentEditingOutput alloc] initWithContentEditingInput:contentEditingInput];
        NSData *jpegData = [outputImage aapl_jpegRepresentationWithCompressionQuality:0.9f];
        [jpegData writeToURL:[contentEditingOutput renderedContentURL] atomically:YES];
        [contentEditingOutput setAdjustmentData:adjustmentData];
        
        // Ask the shared PHPhotoLinrary to perform the changes.
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetChangeRequest *request = [PHAssetChangeRequest changeRequestForAsset:self.asset];
            request.contentEditingOutput = contentEditingOutput;
        } completionHandler:^(BOOL success, NSError *error) {
            if (!success) {
                NSLog(@"Error: %@", error);
            }
        }];
    }];
}

- (void)toggleFavoriteState {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *request = [PHAssetChangeRequest changeRequestForAsset:self.asset];
        [request setFavorite:![self.asset isFavorite]];
    } completionHandler:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"Error: %@", error);
        }
    }];
}

- (void)revertToOriginal {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *request = [PHAssetChangeRequest changeRequestForAsset:self.asset];
        [request revertAssetContentToOriginal];
    } completionHandler:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"Error: %@", error);
        }
    }];
}

@end
