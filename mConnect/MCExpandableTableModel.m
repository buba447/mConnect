//
//  MCExpandableTableModel.m
//  mConnect
//
//  Created by Brandon Withrow on 7/12/14.
//  Copyright (c) 2014 Brandon Withrow. All rights reserved.
//

#import "MCExpandableTableModel.h"
#import "MCDAGTableViewCell.h"
#import "MCStreamClient.h"
#import "MCStreamRequest.h"

@implementation MCDAGObject

- (instancetype)initWithObject:(id)object {
  self = [super init];
  if (self) {
    if ([object isKindOfClass:[NSString class]]) {
      //Single Object
      self.title = (NSString *)object;
    } else if ([object isKindOfClass:[NSDictionary class]]) {
      //Has Children
      NSDictionary *dict = (NSDictionary *)object;
      self.title = dict.allKeys.firstObject;
      NSArray *children = [dict objectForKey:self.title];
      NSMutableArray *dagChildren = [NSMutableArray array];
      for (id child in children) {
        MCDAGObject *dagChild = [[MCDAGObject alloc] initWithObject:child];
        dagChild.parent = self;
        [dagChildren addObject:dagChild];
      }
      _children = dagChildren;
    }
  }
  return self;
}

- (void)getAttrsWithCompletion:(void (^)(void))completion {
  NSString *pyMessage = [NSString stringWithFormat:@"bw.lsKeyableAttr('%@')", self.title];
  __weak typeof(self) weakSelf = self;
  [[MCStreamClient sharedClient] sendPyCommand:pyMessage withCompletion:^(NSString *response) {
    __strong typeof(self) strongSelf = weakSelf;
    [strongSelf _setAttrsWithJSON:response];
    if (completion) {
      completion();
    }
  } withFailure:NULL];
}

- (void)_setAttrsWithJSON:(NSString *)json {
  NSError *error;
  NSLog(@"RECIEVED %@", json);
  if (json) {
    NSData *metOfficeData = [json dataUsingEncoding:NSUTF8StringEncoding];
    id jsonObject = [NSJSONSerialization JSONObjectWithData:metOfficeData options:kNilOptions error:&error];
    if (error) {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"ERROR %li", (long)error.code] message:error.domain delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles:nil];
      [alert show];
    } else {
      _attrs = (NSDictionary*)jsonObject;
    }
  }
}

- (int)depth {
  if (self.parent) {
    return self.parent.depth + 1;
  } else {
    return 0;
  }
}

- (NSArray *)flattenedTree {
  NSMutableArray *returnArray = [NSMutableArray array];
  [returnArray addObject:self];
  for (MCDAGObject *child in self.children) {
    [returnArray addObjectsFromArray:child.flattenedTree];
  }
  return returnArray;
}

- (BOOL)visible {
  BOOL visible = NO;
  if (self.parent) {
    visible = self.parent.expanded && self.parent.visible;
  } else {
    visible = YES;
  }
  return visible;
}

- (NSString *)prettyName {
  if (self.title) {
    NSArray *names = [self.title componentsSeparatedByString:@":"];
    return names.lastObject;
  }
  return nil;
}

@end

@implementation MCExpandableTableModel

- (void)setJsonObject:(id)jsonObject {
  if (_jsonObject) {
    
  }
  _jsonObject = jsonObject;
  if ([jsonObject isKindOfClass:[NSArray class]]) {
    NSArray *jsonTree = (NSArray *)jsonObject;
    NSMutableArray *sceneTree = [NSMutableArray array];
    for (id object in jsonTree) {
      MCDAGObject *child = [[MCDAGObject alloc] initWithObject:object];
      [sceneTree addObject:child];
    }
    NSLog(@"Scene Expanded");
    _itemsTree = sceneTree;
    NSMutableArray *flattenedTree = [NSMutableArray array];
    for (MCDAGObject *child in sceneTree) {
      [flattenedTree addObjectsFromArray:child.flattenedTree];
    }
    NSLog(@"Scene flattened");
    _itemsFlattened = flattenedTree;
  }
  [self.tableView reloadData];
}

- (void)setTableView:(UITableView *)tableView {
  _tableView = tableView;
  _tableView.delegate = self;
  _tableView.dataSource = self;
  [_tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.itemsFlattened.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString *identifier = @"cell";
  MCDAGTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
  if (!cell) {
    cell = [[MCDAGTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
  }
  MCDAGObject *child = [self.itemsFlattened objectAtIndex:indexPath.row];
  cell.dagObject = child;
  return cell;
}

#pragma mark - UITableViewDelegate

//- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
//{
//  return YES;
//}
//
//- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
//{
////  NSString *stringToMove = self.tableData[sourceIndexPath.row];
////  [self.tableData removeObjectAtIndex:sourceIndexPath.row];
////  [self.tableData insertObject:stringToMove atIndex:destinationIndexPath.row];
////  int offset = (int)(destinationIndexPath.row - sourceIndexPath.row);
////  MCDAGObject *child = [self.itemsFlattened objectAtIndex:sourceIndexPath.row];
////  NSString *message = [NSString stringWithFormat:@"cmds.reorder( '%@', r=%i )", child.title, offset];
////  __weak typeof(self) weakSelf = self;
////  [[MCStreamClient sharedClient] sendMessage:message
////                                   withBlock:^(NSString *returnString) {
////                                     __strong typeof(self) strongSelf = weakSelf;
////                                     [strongSelf reloadSceneGraph];
////                                   }];
//  
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  MCDAGObject *child = [self.itemsFlattened objectAtIndex:indexPath.row];
  return [MCDAGTableViewCell heightForDagObject:child];
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
  MCDAGObject *child = [self.itemsFlattened objectAtIndex:indexPath.row];
  return child.depth;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (self.delegate &&
      [self.delegate respondsToSelector:@selector(expandableTableModel:didSelectRowAtIndex:)]) {
    [self.delegate expandableTableModel:self didSelectRowAtIndex:indexPath];
  }
  
  MCDAGObject *child = [self.itemsFlattened objectAtIndex:indexPath.row];
  [[MCStreamClient sharedClient] selectObject:child.title];
//  if (child.children) {
//    child.expanded = !child.expanded;
//    [tableView reloadData];
//  }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
  return UITableViewCellEditingStyleNone;
}

@end
