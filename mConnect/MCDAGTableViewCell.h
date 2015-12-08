//
//  MCDAGTableViewCell.h
//  mConnect
//
//  Created by Brandon Withrow on 7/12/14.
//  Copyright (c) 2014 Brandon Withrow. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MCDAGObject;
@interface MCDAGTableViewCell : UITableViewCell

@property (nonatomic, strong) MCDAGObject *dagObject;

+ (CGFloat)heightForDagObject:(MCDAGObject *)dag;
@end
