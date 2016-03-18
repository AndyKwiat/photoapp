//
//  TagsMenuCell.m
//  Tagger
//
//  Created by Andy Kwiatkowski on 2016-01-22.
//
//

#import "TagsMenuCell.h"

@interface TagsMenuCell ()
@property (weak, nonatomic) IBOutlet UILabel *tagLabel;
@property (weak, nonatomic) IBOutlet UILabel *photoCountLabel;
@end

@implementation TagsMenuCell

-(void)SetPhotoCount:(int)count
{
    _photoCountLabel.text = [NSString stringWithFormat:@"%d",count];
}
-(void)SetLabel:(NSString *)label
{
    _tagLabel.text = label;
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
