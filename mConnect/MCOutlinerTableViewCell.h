//
//  MCOutlinerTableViewCell.h
//  mConnect
//
//  Created by Brandon Withrow on 7/16/14.
//  Copyright (c) 2014 Brandon Withrow. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MCOutlinerTableViewCell;
@protocol MCOutlinerTableViewCellDelegate <NSObject>

- (void)outlinerTableCellDidExpand:(MCOutlinerTableViewCell *)oCell;

@end

@class MCOutlinerObject;
@interface MCOutlinerTableViewCell : UITableViewCell

@property (nonatomic, strong) MCOutlinerObject *outlinerObject;
@property (nonatomic, assign) BOOL isExpanded;
@property (nonatomic, assign) id <MCOutlinerTableViewCellDelegate>actionDelegate;

@end
