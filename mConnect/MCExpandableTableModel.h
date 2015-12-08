//
//  MCExpandableTableModel.h
//  mConnect
//
//  Created by Brandon Withrow on 7/12/14.
//  Copyright (c) 2014 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MCExpandableTableModel;
@protocol MCExpandableTableModelDelegate <NSObject>

@optional
- (void)expandableTableModel:(MCExpandableTableModel*)tableModel didSelectRowAtIndex:(NSIndexPath*)indexPath;

@end

@interface MCDAGObject : NSObject

@property (nonatomic, readonly) BOOL visible;
@property (nonatomic, assign) BOOL expanded;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, readonly) NSString *prettyName;
@property (nonatomic, assign) int depth;
@property (nonatomic, strong) NSArray *children;
@property (nonatomic, assign) MCDAGObject *parent;

@property (nonatomic, readonly) NSDictionary *attrs;

@property (nonatomic, readonly) NSArray *flattenedTree;

- (id)initWithObject:(id)object;
- (void)getAttrsWithCompletion:(void (^)(void))completion;

@end

@interface MCExpandableTableModel : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) id jsonObject;
@property (nonatomic, readonly) NSArray *itemsTree;
@property (nonatomic, readonly) NSArray *itemsFlattened;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) id <MCExpandableTableModelDelegate>delegate;
@end
