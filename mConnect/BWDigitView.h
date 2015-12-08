//
//  BWDigitView.h
//  ClockGlitch
//
//  Created by Brandon Withrow on 8/9/15.
//  Copyright (c) 2015 Brandon Withrow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BWDigitView : UIView

// Displayed value of the digit
@property (nonatomic, assign) NSInteger faceValue;

// how fast digits are elements cycling
@property (nonatomic, assign) CGFloat frequency;

// How much the digits overlap when they cycle
@property (nonatomic, assign) CGFloat phase;

// How much the digits overlap when they cycle
@property (nonatomic, assign) CGFloat onOffRatio;

- (void)setAllOnOverride;
- (void)setAllOffOverride;
- (void)setNumberOnOverride;
- (void)resetOverride;

@end
