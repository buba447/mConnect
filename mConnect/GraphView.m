//
//  GraphView.m
//  mConnect
//
//  Created by Brandon Withrow on 8/3/15.
//  Copyright (c) 2015 Brandon Withrow. All rights reserved.
//

#import "GraphView.h"
#import "BWMath.h"

@implementation GraphView {
  NSMutableArray *values;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    values = [NSMutableArray array];
    for ( int i = 0; i < 80; i++) {
      [values addObject:@(0)];
    }
  }
  return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
  
  [[UIColor mayaBackgroundColor] setFill];
  UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
  [path fill];
  
  CGFloat xInterval = self.bounds.size.width / values.count;
  
  CGFloat maxValue = [[values valueForKeyPath:@"@max.floatValue"] floatValue];
  if (maxValue == 0) {
    maxValue = self.bounds.size.height * 0.5;
  }
  CGFloat minValue = maxValue * -1;
  
  maxValue = 90;
  minValue = -90;
  
  
  UIBezierPath *path2 = [UIBezierPath bezierPath];
  path2.lineWidth = 3;

  for ( int i = 0; i < values.count; i++) {
    // Construct point
    CGFloat xVal = i * xInterval;
    CGFloat yVal = RemapValue([values[i] floatValue], minValue, maxValue, 0, self.bounds.size.height);
    yVal = self.bounds.size.height - yVal;
    CGPoint point = CGPointMake(xVal, yVal);
    if (i == 0) {
      [path2 moveToPoint:point];
    } else {
      [path2 addLineToPoint:point];
    }
  }
  [[UIColor mayaSelectionColor] setStroke];
  [path2 stroke];
  
  [path2 removeAllPoints];
  path2.lineWidth = 1;
  [path2 moveToPoint:CGPointMake(0, self.bounds.size.height * 0.5)];
  [path2 addLineToPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height * 0.5)];
  [[UIColor mayaActiveColor] setStroke];
  [path2 stroke];
  
}

- (void)pushValueOntoStack:(CGFloat)value {
  [values addObject:@(value)];
  [values removeObjectAtIndex:0];
  [self setNeedsDisplay];
}

@end
