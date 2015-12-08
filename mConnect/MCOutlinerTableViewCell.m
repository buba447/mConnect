//
//  MCOutlinerTableViewCell.m
//  mConnect
//
//  Created by Brandon Withrow on 7/16/14.
//  Copyright (c) 2014 Brandon Withrow. All rights reserved.
//

#import "MCOutlinerTableViewCell.h"
#import "MCOutlinerObject.h"

@interface MCOutlinerTableViewCell ()

@property (nonatomic, strong) UIButton *expandButton;

@end

@implementation MCOutlinerTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
      self.contentView.backgroundColor = [UIColor mayaBackgroundColor];
      self.textLabel.textColor = [UIColor whiteColor];
      self.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
      self.selectedBackgroundView.backgroundColor = [UIColor mayaSelectionColor];
      _expandButton = [UIButton buttonWithType:UIButtonTypeCustom];
      [_expandButton setImage:[UIImage imageNamed:@"expand_button.png"] forState:UIControlStateNormal];
      [_expandButton addTarget:self action:@selector(expandButtonPressed) forControlEvents:UIControlEventTouchUpInside];
      [self.contentView addSubview:_expandButton];
    }
    return self;
}

- (void)expandButtonPressed {
  if (self.actionDelegate &&
      [self.actionDelegate respondsToSelector:@selector(outlinerTableCellDidExpand:)]) {
    [self.actionDelegate outlinerTableCellDidExpand:self];
  }
}

- (void)setOutlinerObject:(MCOutlinerObject *)outlinerObject {
  _outlinerObject = outlinerObject;
  self.textLabel.text = outlinerObject.prettyName;
  self.expandButton.hidden = (outlinerObject.childCount == 0);
}

- (void)prepareForReuse {
  [super prepareForReuse];
  self.outlinerObject = nil;
  self.isExpanded = NO;
  self.actionDelegate = nil;
}

- (void)setIsExpanded:(BOOL)isExpanded {
  _isExpanded = isExpanded;
  if (isExpanded) {
    [_expandButton setImage:[UIImage imageNamed:@"collapse_button.png"] forState:UIControlStateNormal];
  } else {
    [_expandButton setImage:[UIImage imageNamed:@"expand_button.png"] forState:UIControlStateNormal];
  }
}

- (void)layoutSubviews {
  [super layoutSubviews];
  CGSize iconSize = self.expandButton.imageView.image.size;
  float iconPadding = 5.f;
  float leftPadding = 10.f;
  leftPadding += (self.outlinerObject.depth * (iconPadding + iconSize.width));

  _expandButton.frame = CGRectFramedLeftInRect(self.contentView.bounds, iconSize, leftPadding, YES);
  float textInset = leftPadding + iconSize.width + iconPadding;
  self.textLabel.frame = CGRectFramedLeftInRect(self.contentView.bounds, self.textLabel.bounds.size, textInset, YES);
}
@end
