//
//  MCOutlinerObject.m
//  mConnect
//
//  Created by Brandon Withrow on 7/16/14.
//  Copyright (c) 2014 Brandon Withrow. All rights reserved.
//

#import "MCOutlinerObject.h"

@implementation MCOutlinerObject

- (id)initWithDictionary:(NSDictionary *)object {
  self = [super init];
  if (self) {
    _title = [object valueForKey:@"title"];
    _childCount = [[object valueForKey:@"childCount"] intValue];
    _depth = 0;
    NSArray *strings1 = [_title componentsSeparatedByString:@"|"];
    NSArray *strings2 = [strings1.lastObject componentsSeparatedByString:@":"];
    _prettyName = strings2.lastObject;
    
  }
  return self;
}

- (void)setParent:(MCOutlinerObject *)parent {
  _parent = parent;
  _depth = parent.depth + 1;
}

- (void)_setChildren:(NSArray *)jsonArray {
  NSMutableArray *children = [NSMutableArray array];
  for (NSDictionary *dictionary in jsonArray) {
    MCOutlinerObject *child = [[MCOutlinerObject alloc] initWithDictionary:dictionary];
    child.parent = self;
    [children addObject:child];
  }
  _children = children;
}

- (void)fetchChildrenWithCompletion:(void (^)(MCOutlinerObject *outlinerObject))completion
                            failure:(void (^)(void))failure {
  __weak typeof(self) weakSelf = self;
  NSString *pyCommand = [NSString stringWithFormat:@"bw.lsOutlinerChildren('%@')", self.title];
  [[MCStreamClient sharedClient] getJSONFromPyCommand:pyCommand
      withCompletion:^(id JSONObject) {
        __strong typeof(self) strongSelf = weakSelf;
        if ([JSONObject isKindOfClass:[NSArray class]]) {
          [strongSelf _setChildren:JSONObject];
        }
        if (completion) {
          completion(strongSelf);
        }
      } withFailure:^{
        if (failure) {
          failure();
        }
      }];
}
@end
