//
//  MCDAGTableViewCell.m
//  mConnect
//
//  Created by Brandon Withrow on 7/12/14.
//  Copyright (c) 2014 Brandon Withrow. All rights reserved.
//

#import "MCDAGTableViewCell.h"
#import "MCExpandableTableModel.h"
#import "MCPYScalarSlider.h"

@implementation MCDAGTableViewCell {
  NSArray *attrViews_;
  UIView *scalarHolder_;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    self.indentationWidth = 25;
    scalarHolder_ = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:scalarHolder_];
  }
  return self;
}

- (void)setDagObject:(MCDAGObject *)dagObject {
  _dagObject = dagObject;
  
  if (dagObject.children) {
    self.textLabel.text = [NSString stringWithFormat:@"(%@) %@", dagObject.expanded ? @"+" : @"-", dagObject.prettyName];
  } else {
    self.textLabel.text = dagObject.prettyName;
  }
  if (dagObject.attrs) {
    NSMutableArray *aViews = [NSMutableArray array];
    for (NSString *key in dagObject.attrs.allKeys) {
      MCPYScalarSlider *newSlider = [[MCPYScalarSlider alloc] initWithFrame:CGRectZero];
      newSlider.dagObject = dagObject;
      newSlider.pyProperty = key;
      [scalarHolder_ addSubview:newSlider];
      [aViews addObject:newSlider];
    }
    attrViews_ = aViews;
  }
}

- (void)prepareForReuse {
  [super prepareForReuse];
  for (UIView *view in attrViews_) {
    [view removeFromSuperview];
  }
  attrViews_ = nil;
}

- (void)layoutSubviews {
  if (!self.dagObject.attrs) {
    [super layoutSubviews];
  } else {
    scalarHolder_.frame = self.contentView.bounds;
    CGRect titleFrame = CGRectZero;
    titleFrame.size = [self.textLabel sizeThatFits:self.bounds.size];
    titleFrame.origin.y = 0;
    titleFrame.origin.x = 20;
    self.textLabel.frame = titleFrame;
    CGRect attrFrame = CGRectMake(5, CGRectGetMaxY(titleFrame) + 5, self.contentView.bounds.size.width - 10, 40);
    for (UIView *view in attrViews_) {
      view.frame = attrFrame;
      attrFrame.origin.y += attrFrame.size.height + 5;
    }
  }
}

+ (CGFloat)heightForDagObject:(MCDAGObject *)dag {
  CGFloat retunHeight = 44;
  if (dag.attrs) {
    retunHeight = 25 + (45 * dag.attrs.allKeys.count);
  }
  if (!dag.visible) {
    retunHeight = 0;
  }
  return retunHeight;
}

@end
