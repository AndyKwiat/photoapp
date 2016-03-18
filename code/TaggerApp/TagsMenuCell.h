//
//  TagsMenuCell.h
//  Tagger
//
//  Created by Andy Kwiatkowski on 2016-01-22.
//
//

#import <UIKit/UIKit.h>
#include"Tag.h"

@interface TagsMenuCell : UITableViewCell

@property (nonatomic) Tag *photoTag;
-(void)SetLabel:(NSString*)label;
-(void)SetPhotoCount:(int)count;
@end
