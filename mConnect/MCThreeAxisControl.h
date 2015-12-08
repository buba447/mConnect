//
//  MCThreeAxisControl.h
//  mConnect
//
//  Created by Brandon Withrow on 5/6/15.
//  Copyright (c) 2015 Brandon Withrow. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
  MCControlUpAxisY,
  MCControlUpAxisX,
  MCControlUpAxisZ
} MCControlUpAxis;

@interface MCThreeAxisControl : UIControl

@property (nonatomic, assign) MCControlUpAxis upAxis;

@property (nonatomic, assign) CGFloat rotation;
@property (nonatomic, strong) UIColor *ringColor;

@property (nonatomic, readonly) GLKVector3 rotationsAbsolute;
@property (nonatomic, readonly) GLKVector3 rotationsRelative;
- (void)resetRelativeAngles;
@end
