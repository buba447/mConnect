//
//  BWDigitView.m
//  ClockGlitch
//
//  Created by Brandon Withrow on 8/9/15.
//  Copyright (c) 2015 Brandon Withrow. All rights reserved.
//

#import "BWDigitView.h"
#import "BWClockElement.h"
#import "BWMath.h"
#import "CGGeometryAdditions.h"

@implementation BWDigitView {
  NSArray *faceElements_;
  NSMutableArray *elementsForDigit_;
  NSMutableArray *loopingElements_;
  BOOL displayOverride_;
}

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    NSMutableArray *elements = [NSMutableArray array];
    for (int i = 0; i < 7; i ++) {
      BWClockElement *clockElement = [[BWClockElement alloc] initWithFrame:CGRectZero];
      clockElement.timeValue = 0.0;
      [self addSubview:clockElement];
      [elements addObject:clockElement];
    }
    faceElements_ = elements;
    elementsForDigit_ = [NSMutableArray array];
    [elementsForDigit_ addObjectsFromArray:elements];
    
    loopingElements_ = [NSMutableArray array];
    [loopingElements_ addObjectsFromArray:elements];
    
    _frequency = 0.01;
    _phase = 0;
    [self _update];
  }
  return self;
}

- (void)_update {
  if (displayOverride_ || loopingElements_.count == 0) {
    return;
  }
  
  NSMutableArray *objectsToLoop = [NSMutableArray array];
  
  BWClockElement *firstElement = loopingElements_[0];
  
  CGFloat startValue = firstElement.timeValue + _frequency;
  
  for (BWClockElement *element in loopingElements_) {
    element.timeValue = startValue;
    
    if (element.timeValue > 1) {
      [objectsToLoop addObject:element];
    }
    startValue -= _phase;
    if (startValue < 0) {
      startValue = 0;
    }
  }
  
  // Now loop Elements if nes.
  for (BWClockElement *element in objectsToLoop) {
    element.timeValue = 0;
    //Move to back
    [loopingElements_ removeObject:element];
    [loopingElements_ addObject:element];
  }
  
  [self performSelector:@selector(_update) withObject:NULL afterDelay:1/24.f];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  CGSize hSize = CGSizeMake(self.bounds.size.width - 20, 20);
  CGSize vSize = CGSizeMake(20, (self.bounds.size.height * 0.5) - 10);
  
  BWClockElement *element = faceElements_[0];
  element.frame = CGRectFramedCenteredInRect(self.bounds, hSize, YES);
  
  element = faceElements_[1];
  element.frame = CGRectFramedTopLeftInRect(self.bounds, vSize, 0, 10, YES);
  
  element = faceElements_[2];
  element.frame = CGRectFramedTopInRect(self.bounds, hSize, 0, YES);
  
  element = faceElements_[3];
  element.frame = CGRectFramedTopRightInRect(self.bounds, vSize, 0, 10, YES);
  
  element = faceElements_[4];
  element.frame = CGRectFramedBottomRightInRect(self.bounds, vSize, 0, 10, YES);
  
  element = faceElements_[5];
  element.frame = CGRectFramedBottomInRect(self.bounds, hSize, 0, YES);
  
  element = faceElements_[6];
  element.frame = CGRectFramedBottomLeftInRect(self.bounds, vSize, 0, 10, YES);
  
}

- (void)setFaceValue:(NSInteger)faceValue {
  _faceValue = MAX(MIN(faceValue, 0), 9);
  [loopingElements_ removeAllObjects];
  [elementsForDigit_ removeAllObjects];
  
  if (faceValue == 0) {
    [elementsForDigit_ addObjectsFromArray:faceElements_];
    [elementsForDigit_ removeObject:faceElements_[0]];
  }
  
  if (faceValue == 1) {
    [elementsForDigit_ addObject:faceElements_[3]];
    [elementsForDigit_ addObject:faceElements_[4]];
  }
  
  if (faceValue == 2) {
    [elementsForDigit_ addObject:faceElements_[2]];
    [elementsForDigit_ addObject:faceElements_[3]];
    [elementsForDigit_ addObject:faceElements_[0]];
    [elementsForDigit_ addObject:faceElements_[6]];
    [elementsForDigit_ addObject:faceElements_[5]];
  }
  
  if (faceValue == 3) {
    [elementsForDigit_ addObject:faceElements_[2]];
    [elementsForDigit_ addObject:faceElements_[3]];
    [elementsForDigit_ addObject:faceElements_[0]];
    [elementsForDigit_ addObject:faceElements_[4]];
    [elementsForDigit_ addObject:faceElements_[5]];
  }
  
  if (faceValue == 4) {
    [elementsForDigit_ addObject:faceElements_[0]];
    [elementsForDigit_ addObject:faceElements_[1]];
    [elementsForDigit_ addObject:faceElements_[3]];
    [elementsForDigit_ addObject:faceElements_[4]];
  }
  
  if (faceValue == 5) {
    [elementsForDigit_ addObject:faceElements_[2]];
    [elementsForDigit_ addObject:faceElements_[1]];
    [elementsForDigit_ addObject:faceElements_[0]];
    [elementsForDigit_ addObject:faceElements_[4]];
    [elementsForDigit_ addObject:faceElements_[5]];
  }
  
  if (faceValue == 6) {
    [elementsForDigit_ addObject:faceElements_[2]];
    [elementsForDigit_ addObject:faceElements_[1]];
    [elementsForDigit_ addObject:faceElements_[0]];
    [elementsForDigit_ addObject:faceElements_[4]];
    [elementsForDigit_ addObject:faceElements_[5]];
    [elementsForDigit_ addObject:faceElements_[6]];
  }
  
  if (faceValue == 7) {
    [elementsForDigit_ addObject:faceElements_[2]];
    [elementsForDigit_ addObject:faceElements_[3]];
    [elementsForDigit_ addObject:faceElements_[4]];
  }
  
  if (faceValue == 8) {
    [elementsForDigit_ addObjectsFromArray:faceElements_];
  }
  
  if (faceValue == 9) {
    [elementsForDigit_ addObject:faceElements_[0]];
    [elementsForDigit_ addObject:faceElements_[1]];
    [elementsForDigit_ addObject:faceElements_[2]];
    [elementsForDigit_ addObject:faceElements_[3]];
    [elementsForDigit_ addObject:faceElements_[4]];
  }
  
  for (BWClockElement *element in faceElements_) {
    element.timeValue = 0;
  }
  [loopingElements_ addObjectsFromArray:elementsForDigit_];
}

- (void)setOnOffRatio:(CGFloat)onOffRatio {
  for (BWClockElement *element in faceElements_) {
    element.onOffRatio = onOffRatio;
  }
  _onOffRatio = onOffRatio;
}

- (void)setAllOnOverride {
  for (BWClockElement *element in faceElements_) {
    element.timeValue = 1;
  }
  displayOverride_ = YES;
}

- (void)setNumberOnOverride {
  [self setAllOffOverride];
  for (BWClockElement *element in elementsForDigit_) {
    element.timeValue = 1;
  }
}

- (void)setAllOffOverride {
  for (BWClockElement *element in faceElements_) {
    element.timeValue = 0;
  }
  displayOverride_ = YES;
}

- (void)resetOverride {
  displayOverride_ = NO;
  [self _update];
}

@end
