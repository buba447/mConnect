//
//  MCKnobView.m
//  mConnect
//
//  Created by Brandon Withrow on 5/5/15.
//  Copyright (c) 2015 Brandon Withrow. All rights reserved.
//

#import "MCThreeAxisControl.h"
#import "UIColor+mcAdditions.h"

static const CGFloat kKnobDiameter = 40.f;

@implementation MCThreeAxisControl {
  UIView *_backgroundCircle;
  UIView *_circleKnob;
  UIView *_centerKnob;
  BOOL trackingCenterKnob_;
  GLKVector3 absoluteAngles_;
  GLKVector3 relativeAngles_;
}

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    trackingCenterKnob_ = NO;
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
    
    _centerKnob = [[UIView alloc] initWithFrame:CGRectZero];
    _centerKnob.backgroundColor = [UIColor mayaActiveColor];
    _centerKnob.layer.borderWidth = 4;
    _centerKnob.layer.borderColor = [UIColor mayaSelectionColor].CGColor;
    _centerKnob.layer.cornerRadius = kKnobDiameter * 0.5;
    _centerKnob.userInteractionEnabled = NO;
    [self addSubview:_centerKnob];

    self.rotation = 0;
    self.upAxis = MCControlUpAxisY;
    
    UITapGestureRecognizer *tappyTapperton = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleDoubleTap)];
    tappyTapperton.numberOfTapsRequired = 2;
    tappyTapperton.cancelsTouchesInView = NO;
    [self addGestureRecognizer:tappyTapperton];
  }
  return self;
}

- (void)_handleDoubleTap {
  NSUInteger axis = self.upAxis;
  axis ++;
  if (axis > MCControlUpAxisZ) {
    axis = 0;
  }
  self.upAxis = (MCControlUpAxis)axis;
}

- (void)setUpAxis:(MCControlUpAxis)upAxis {
  _upAxis = upAxis;
  switch (upAxis) {
    case MCControlUpAxisY:
      self.ringColor = [UIColor greenColor];
      break;
    case MCControlUpAxisX:
      self.ringColor = [UIColor redColor];
      break;
    case MCControlUpAxisZ:
      self.ringColor = [UIColor blueColor];
      break;
    default:
      break;
  }
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
  [self _layoutCenterKnob];
}

- (void)setRotation:(CGFloat)rotation {
  if (rotation != _rotation) {
    _rotation = rotation;
    [self _layoutKnob];
  }
}

- (void)_layoutCenterKnob {
  CGRect circleRect = [self _circleRect];
  CGPoint center = CGRectGetCenterPoint(circleRect);
  _centerKnob.bounds = CGRectMake(0, 0, kKnobDiameter, kKnobDiameter);
  _centerKnob.center = center;
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

// Touch Tracking

-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
  absoluteAngles_ = GLKVector3Make(0, 0, 0);
  relativeAngles_ = GLKVector3Make(0, 0, 0);
  if (CGRectContainsPoint(_centerKnob.frame, [touch locationInView:self])) {
    trackingCenterKnob_ = YES;
    return YES;
  }
  if (CGRectContainsPoint(_circleKnob.frame, [touch locationInView:self])) {
    return YES;
  }
  return NO;
}

-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
  if (trackingCenterKnob_) {
    CGPoint loc = [touch locationInView:self];
    _centerKnob.center = CGPointMake(CLAMP(loc.x, 0, self.bounds.size.width), CLAMP(loc.y, 0, self.bounds.size.height));
    
    CGPoint center = CGRectGetCenterPoint(self.bounds);
    
    CGPoint adjLoc = CGPointMake(loc.x - center.x, loc.y - center.y);
    adjLoc.x *= -1;
    adjLoc.y *= -1;
    CGFloat vertAngle = RadiansToDegrees(atan2(adjLoc.y, self.bounds.size.width));
    CGFloat horzAngle = RadiansToDegrees(atan2(adjLoc.x, self.bounds.size.height));
    
    relativeAngles_.z += (horzAngle - absoluteAngles_.z);
    absoluteAngles_.z = horzAngle;
    
    relativeAngles_.x += (vertAngle - absoluteAngles_.x);
    absoluteAngles_.x = vertAngle;
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
  }
  
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
  
  relativeAngles_.y += diff;
  absoluteAngles_.y = self.rotation;
  
  [self sendActionsForControlEvents:UIControlEventValueChanged];
  return YES;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
  trackingCenterKnob_ = NO;
  absoluteAngles_ = GLKVector3Make(0, 0, 0);
  relativeAngles_ = GLKVector3Make(0, 0, 0);
  [UIView animateWithDuration:0.1 animations:^{
    self.rotation = 0;
    [self _layoutCenterKnob];
  } completion:^(BOOL finished) {
    
  }];
  
}

- (GLKVector3)rotationsAbsolute {
  GLKVector3 returnRotations;
  switch (self.upAxis) {
    case MCControlUpAxisY:
      returnRotations = GLKVector3Make(absoluteAngles_.x, absoluteAngles_.y, absoluteAngles_.z);
      break;
    case MCControlUpAxisX:
      returnRotations = GLKVector3Make(absoluteAngles_.y, absoluteAngles_.z, absoluteAngles_.x);
      break;
    case MCControlUpAxisZ:
      returnRotations = GLKVector3Make(absoluteAngles_.x, absoluteAngles_.z, absoluteAngles_.y);
      break;
    default:
      break;
  }
  return returnRotations;
}

- (GLKVector3)rotationsRelative {
  GLKVector3 returnRotations;
  switch (self.upAxis) {
    case MCControlUpAxisY:
      returnRotations = GLKVector3Make(relativeAngles_.x, relativeAngles_.y, relativeAngles_.z);
      break;
    case MCControlUpAxisX:
      returnRotations = GLKVector3Make(relativeAngles_.y, relativeAngles_.z, relativeAngles_.x);
      break;
    case MCControlUpAxisZ:
      returnRotations = GLKVector3Make(relativeAngles_.x, relativeAngles_.z, relativeAngles_.y);
      break;
    default:
      break;
  }
  return returnRotations;
}

- (void)resetRelativeAngles {
  relativeAngles_ = GLKVector3Make(0, 0, 0);
}
@end
