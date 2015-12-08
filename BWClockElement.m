//
//  BWClockElement.m
//  ClockGlitch
//
//  Created by Brandon Withrow on 8/9/15.
//  Copyright (c) 2015 Brandon Withrow. All rights reserved.
//

#import "BWClockElement.h"
#import "BWMath.h"

@implementation BWClockElement

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _onOffRatio = 0.0001;
    self.backgroundColor = [UIColor clearColor];
  }
  return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
  CGRect drawRect = CGRectInset(rect, 2, 2);
  CGFloat miterSize = (drawRect.size.width > drawRect.size.height ?
                       drawRect.size.height * 0.5 :
                       drawRect.size.width * 0.5);
  
  UIBezierPath *path = [UIBezierPath bezierPath];
  
  if (drawRect.size.width > drawRect.size.height) {
    [path moveToPoint:CGPointMake(CGRectGetMinX(drawRect) + miterSize, CGRectGetMinY(drawRect))];
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(drawRect) - miterSize, CGRectGetMinY(drawRect))];
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(drawRect), CGRectGetMinY(drawRect) + miterSize)];
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(drawRect) - miterSize, CGRectGetMaxY(drawRect))];
    
    [path addLineToPoint:CGPointMake(CGRectGetMinX(drawRect) + miterSize, CGRectGetMaxY(drawRect))];
    [path addLineToPoint:CGPointMake(CGRectGetMinX(drawRect), CGRectGetMaxY(drawRect) - miterSize)];
    [path addLineToPoint:CGPointMake(CGRectGetMinX(drawRect) + miterSize, CGRectGetMinY(drawRect))];
  } else {
    
    
    [path moveToPoint:CGPointMake(CGRectGetMinX(drawRect) + miterSize, CGRectGetMinY(drawRect))];
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(drawRect), CGRectGetMinY(drawRect) + miterSize)];
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(drawRect), CGRectGetMaxY(drawRect) - miterSize)];
    
    
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(drawRect) - miterSize, CGRectGetMaxY(drawRect))];
    [path addLineToPoint:CGPointMake(CGRectGetMinX(drawRect), CGRectGetMaxY(drawRect) - miterSize)];
    [path addLineToPoint:CGPointMake(CGRectGetMinX(drawRect), CGRectGetMinY(drawRect) + miterSize)];
    
    [path addLineToPoint:CGPointMake(CGRectGetMinX(drawRect) + miterSize, CGRectGetMinY(drawRect))];
  }
  
  UIColor *fillColor;
  if (_timeValue < _onOffRatio || _timeValue == 0) {
    fillColor = [UIColor clearColor];
  } else {
    fillColor = [UIColor redColor];
  }
  [fillColor setFill];
  [path fill];
}


-(void)setTimeValue:(CGFloat)timeValue {
  _timeValue = timeValue;
  [self setNeedsDisplay];
}

@end
