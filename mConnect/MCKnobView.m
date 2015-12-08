//
//  MCKnobView.m
//  mConnect
//
//  Created by Brandon Withrow on 5/5/15.
//  Copyright (c) 2015 Brandon Withrow. All rights reserved.
//

#import "MCKnobView.h"
#import "UIColor+mcAdditions.h"

static const CGFloat kKnobDiameter = 40.f;

@implementation MCKnobView {
  UIView *_backgroundCircle;
  UIView *_circleKnob;
  UILabel *_rotationLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _rotation = 0.0f;
    _backgroundCircle = [[UIView alloc] initWithFrame:self.bounds];
    _backgroundCircle.layer.borderWidth = 4;
    _backgroundCircle.userInteractionEnabled = NO;
    [self addSubview:_backgroundCircle];
    
    _circleKnob = [[UIView alloc] initWithFrame:CGRectZero];
    _circleKnob.backgroundColor = [UIColor mayaActiveColor];
    _circleKnob.layer.borderWidth = 4;
    _circleKnob.layer.cornerRadius = kKnobDiameter * 0.5;
    _circleKnob.userInteractionEnabled = NO;
    [self addSubview:_circleKnob];
    
    _rotationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _rotationLabel.text = @"0.0°";
    _rotationLabel.textColor = [UIColor whiteColor];
    _rotationLabel.font = [UIFont boldSystemFontOfSize:24];
    _rotationLabel.userInteractionEnabled = NO;
    [self addSubview:_rotationLabel];
    self.rotation = 0;
    
    UITapGestureRecognizer *tappyTapperton = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleDoubleTap)];
    tappyTapperton.numberOfTapsRequired = 2;
    tappyTapperton.cancelsTouchesInView = NO;
    [self addGestureRecognizer:tappyTapperton];
    
    self.ringColor = [UIColor mayaSelectionColor];
  }
  return self;
}

- (void)setRingColor:(UIColor *)ringColor {
  _ringColor = ringColor;
  _backgroundCircle.layer.borderColor = ringColor.CGColor;
  _circleKnob.layer.borderColor = ringColor.CGColor;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  [self _layoutBackgroundCircle];
  [self _layoutKnob];
  [self _layoutLabel];
}

- (void)setRotation:(CGFloat)rotation {
  if (rotation != _rotation) {
    _rotation = rotation;
    _rotationLabel.text = [NSString stringWithFormat:@"%.01f°", _rotation];
    [self _layoutKnob];
    [self _layoutLabel];
  }
}

- (void)_layoutBackgroundCircle {
  CGRect circleRect = [self _circleRect];
  _backgroundCircle.frame = circleRect;
  _backgroundCircle.layer.cornerRadius = 0.5 * circleRect.size.width;
}

- (CGRect)_circleRect {
  return CGRectInset(self.bounds, kKnobDiameter * 0.5, kKnobDiameter * 0.5);
}

- (void)_layoutKnob {
  _circleKnob.bounds = CGRectMake(0, 0, kKnobDiameter, kKnobDiameter);
  _circleKnob.center = [self _centerOfKnob];
}

- (CGPoint)_centerOfKnob {
  CGRect circleRect = [self _circleRect];
  CGPoint circlePoint = PointOnCircleAtAngle(circleRect.size.width * 0.5, CGRectGetCenterPoint(circleRect), -1 * (self.rotation + 90));
  return circlePoint;
}

- (void)_layoutLabel {
  _rotationLabel.frame = CGRectFramedCenteredInRect(self.bounds, [_rotationLabel sizeThatFits:self.bounds.size], YES);
}

// Touch Tracking

-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
  return YES;
}

-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
  CGPoint touchPoint = [touch locationInView:self];
  CGPoint center = CGRectGetCenterPoint(self.bounds);
  CGPoint currentPoint = [self _centerOfKnob];
  
  CGPoint adjustedCurrent = CGPointMake(currentPoint.x - center.x, currentPoint.y - center.y);
  CGPoint adjustedTouch = CGPointMake(touchPoint.x - center.x, touchPoint.y - center.y);
  
  CGFloat touchAngle = RadiansToDegrees(atan2(adjustedTouch.y, adjustedTouch.x));
  CGFloat currentAngle = RadiansToDegrees(atan2(adjustedCurrent.y, adjustedCurrent.x));
  touchAngle *= -1;
  currentAngle *= -1;
  // Change of base
  CGFloat diff = touchAngle - currentAngle;
  if (currentPoint.x < center.x && touchPoint.x < center.x && (fabs(diff) > 180)) {
    CGFloat angle1 = RadiansToDegrees(atan2(fabs(adjustedTouch.y), fabs(adjustedTouch.x)));
    CGFloat angle2 = RadiansToDegrees(atan2(fabs(adjustedCurrent.y), fabs(adjustedCurrent.x)));
    diff = angle1 + angle2;
    if (currentAngle < 0) {
      diff *= -1;
    }
  }
  
  self.rotation += diff;
  [self sendActionsForControlEvents:UIControlEventValueChanged];
  return YES;
}

- (void)_handleDoubleTap {
  self.rotation = 0;
  [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end
