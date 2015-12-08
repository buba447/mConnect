//
//  MCPropertyControl.m
//  mConnect
//
//  Created by Brandon Withrow on 5/7/15.
//  Copyright (c) 2015 Brandon Withrow. All rights reserved.
//

#import "MCPropertyControl.h"

@implementation MCPropertyControl {
  UILabel *nameLabel_;
  UILabel *valueLabel_;
  NSTimeInterval previousTime_;
}

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.backgroundColor = [UIColor mayaBackgroundColor];
    _relativeValue = 0;
    nameLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    nameLabel_.textColor = [UIColor whiteColor];
    nameLabel_.userInteractionEnabled = NO;
    [self addSubview:nameLabel_];
    
    valueLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    valueLabel_.textColor = [UIColor whiteColor];
    valueLabel_.userInteractionEnabled = NO;
    [self addSubview:valueLabel_];
    self.layer.borderColor = [UIColor colorWithWhite:0 alpha:0.4].CGColor;
    self.layer.borderWidth = 1;
    self.absoluteValue = 0;
    self.perPixelResolution = 0.01;
    UITapGestureRecognizer *tappyTapperton = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleDoubleTap)];
    tappyTapperton.numberOfTapsRequired = 2;
    tappyTapperton.cancelsTouchesInView = NO;
    [self addGestureRecognizer:tappyTapperton];
  }
  return self;
}

- (void)_handleDoubleTap {
  self.absoluteValue = 0;
  [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  [self _layoutNameLabel];
  [self _layoutValueLabel];
}

- (void)_layoutNameLabel {
  nameLabel_.frame = CGRectFramedLeftInRect(self.bounds, [nameLabel_ sizeThatFits:self.bounds.size], 4, YES);
}

- (void)_layoutValueLabel {
  valueLabel_.frame = CGRectFramedRightInRect(self.bounds, [valueLabel_ sizeThatFits:self.bounds.size], 4, YES);
}

- (void)resetRelativeValue {
  _relativeValue = 0;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
  previousTime_ = event.timestamp;
  self.backgroundColor = [UIColor mayaSelectionColor];
  return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
  CGFloat location = [touch locationInView:self].x;
  CGFloat prevLocation = [touch previousLocationInView:self].x;
  CGFloat diff = location - prevLocation;
  NSTimeInterval timeSincePrevious = event.timestamp - previousTime_;
  CGFloat speed = fabs((diff/timeSincePrevious) * 0.01);
  NSLog(@"%f", speed);
  previousTime_ = event.timestamp;
  diff *= (self.perPixelResolution * speed);
  self.absoluteValue += diff;
  _relativeValue += diff;

  [self sendActionsForControlEvents:UIControlEventValueChanged];
  return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
  self.backgroundColor = [UIColor mayaBackgroundColor];
}

- (void)setAbsoluteValue:(CGFloat)absoluteValue {
  _absoluteValue = absoluteValue;
  valueLabel_.text = [NSString stringWithFormat:@"%.04f", _absoluteValue];
  [self _layoutValueLabel];
}

- (void)setNiceName:(NSString *)name {
  _niceName = name;
  nameLabel_.text = name;
  [self _layoutNameLabel];
}


@end
