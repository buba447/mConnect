//
//  MCOutlinerViewController.m
//  mConnect
//
//  Created by Brandon Withrow on 7/16/14.
//  Copyright (c) 2014 Brandon Withrow. All rights reserved.
//

#import "MCOutlinerViewController.h"
#import "MCOutlinerObject.h"
#import "MCOutlinerTableViewCell.h"
#import "MCMeshView.h"

@interface MCOutlinerViewController () <UITableViewDataSource, UITableViewDelegate, MCOutlinerTableViewCellDelegate>
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation MCOutlinerViewController {
  NSMutableArray *outlinerObjects_;
  NSMutableArray *expanedObjects_;
  NSArray *topLevelArray_;
}

- (id)init {
    self = [super init];
    if (self) {
        // Custom initialization
      outlinerObjects_ = [NSMutableArray array];
      expanedObjects_ = [NSMutableArray array];
      __weak typeof(self) weakSelf = self;
      [[MCStreamClient sharedClient] getJSONFromPyCommand:@"bw.lsOutlinerObjects()"
        withCompletion:^(id JSONObject) {
          __strong typeof(self) strongSelf = weakSelf;
          if ([JSONObject isKindOfClass:[NSArray class]]) {
            [strongSelf _setObjectsFromJSON:JSONObject];
          }
        } withFailure:NULL];
    }
    return self;
}

- (void)_setObjectsFromJSON:(NSArray *)json {
  NSMutableArray *objects = [NSMutableArray array];
  for (NSDictionary *object in json) {
    MCOutlinerObject *child = [[MCOutlinerObject alloc] initWithDictionary:object];
    [objects addObject:child];
  }
  [outlinerObjects_ removeAllObjects];
  [expanedObjects_ removeAllObjects];
  [outlinerObjects_ addObjectsFromArray:objects];
  topLevelArray_ = objects;
  if (objects.count) {
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
  } else {
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
  }
  if (self.isViewLoaded) {
    [self.tableView reloadData];
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
  self.tableView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
  
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  
  self.view.backgroundColor = [UIColor mayaBackgroundColor];
  self.tableView.backgroundColor = [UIColor mayaBackgroundColor];
  [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return outlinerObjects_.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString *cellString = @"mcCell";
  MCOutlinerTableViewCell *oCell = (MCOutlinerTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellString];
  if (!oCell) {
    oCell = [[MCOutlinerTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellString];
  }
  oCell.outlinerObject = [outlinerObjects_ objectAtIndex:indexPath.row];
  oCell.actionDelegate = self;
  oCell.isExpanded = [expanedObjects_ containsObject:oCell.outlinerObject];
  return oCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  MCOutlinerObject *object = [outlinerObjects_ objectAtIndex:indexPath.row];
  
  MCMeshView *newMesh = [[MCMeshView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 450, 450, 450) andMeshName:object.title];
  [self.view addSubview:newMesh];
//  [[MCStreamClient sharedClient] selectObject:object.title];
}

#pragma mark - OutlinerCellDelegate

- (NSArray *)indexPathsForChildrenOfObject:(MCOutlinerObject *)object {
  NSUInteger index = [outlinerObjects_ indexOfObject:object];
  NSMutableArray *returnArray = [NSMutableArray array];
  for (NSUInteger i = 1; i <= object.children.count; i ++) {
    [returnArray addObject:[NSIndexPath indexPathForRow:i + index inSection:0]];
  }
  return returnArray;
}

- (void)outlinerTableCellDidExpand:(MCOutlinerTableViewCell *)oCell {
  if ([expanedObjects_ containsObject:oCell.outlinerObject]) {
    //Already Expanded, Collapse
    MCOutlinerObject *object = oCell.outlinerObject;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"depth <= %i", object.depth];
    NSArray *depthClip = [outlinerObjects_ filteredArrayUsingPredicate:predicate];
    NSUInteger fIndex = [outlinerObjects_ indexOfObject:object] + 1;
    NSUInteger tIndex;
    if (depthClip.lastObject == object) {
      tIndex = outlinerObjects_.count;
    } else {
      NSUInteger cIndex = [depthClip indexOfObject:object];
      MCOutlinerObject *tObject = [depthClip objectAtIndex:cIndex + 1];
      tIndex = [outlinerObjects_ indexOfObject:tObject];
    }

    NSIndexSet *rIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(fIndex, tIndex - fIndex)];
    NSArray *objectsToRemove = [outlinerObjects_ objectsAtIndexes:rIndexes];
    [outlinerObjects_ removeObjectsAtIndexes:rIndexes];
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    [rIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
      [indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
    }];
    
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    oCell.isExpanded = NO;
    [expanedObjects_ removeObjectsInArray:objectsToRemove];
    [expanedObjects_ removeObject:object];
  } else {
    __weak typeof(self) weakSelf = self;
    [oCell.outlinerObject fetchChildrenWithCompletion:^(MCOutlinerObject *outlinerObject) {
      __strong typeof(self) strongSelf = weakSelf;
      if (outlinerObject.children.count) {
        [strongSelf _handleExpandLoaded:outlinerObject];
      } else {
        [strongSelf _handleFailure:outlinerObject];
      }
    } failure:NULL];
  }
}

- (void)_handleExpandLoaded:(MCOutlinerObject *)object {
  // Add rows to datasource
  NSUInteger oIndex = [outlinerObjects_ indexOfObject:object];
  NSArray *indexPaths = [self indexPathsForChildrenOfObject:object];
  
  MCOutlinerTableViewCell *oCell = (MCOutlinerTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:oIndex inSection:0]];
  [expanedObjects_ addObject:object];
  [outlinerObjects_ insertObjects:object.children atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(oIndex + 1, object.children.count)]];
  [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
  oCell.isExpanded = YES;
}

- (void)_handleFailure:(MCOutlinerObject *)object {
  [self.tableView reloadData];
}

@end
