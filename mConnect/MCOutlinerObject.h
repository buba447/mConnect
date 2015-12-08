//
//  MCOutlinerObject.h
//  mConnect
//
//  Created by Brandon Withrow on 7/16/14.
//  Copyright (c) 2014 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCOutlinerObject : NSObject

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) int childCount;
@property (nonatomic, readonly) NSArray *children;
@property (nonatomic, assign) MCOutlinerObject *parent;
@property (nonatomic, readonly) int depth;
@property (nonatomic, readonly) NSString *prettyName;
- (id)initWithDictionary:(NSDictionary *)object;

- (void)fetchChildrenWithCompletion:(void (^)(MCOutlinerObject *outlinerObject))completion failure:(void (^)(void))failure;

@end
