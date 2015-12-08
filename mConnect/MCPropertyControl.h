//
//  MCPropertyControl.h
//  mConnect
//
//  Created by Brandon Withrow on 5/7/15.
//  Copyright (c) 2015 Brandon Withrow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCPropertyControl : UIControl

@property (nonatomic, strong) NSString *niceName;
@property (nonatomic, strong) NSString *propName;
@property (nonatomic, assign) CGFloat absoluteValue;
@property (nonatomic, readonly) CGFloat relativeValue;
@property (nonatomic, assign) CGFloat perPixelResolution;
- (void)resetRelativeValue;

@end
