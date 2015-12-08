//
//  MCPYScalarSlider.m
//  mConnect
//
//  Created by Brandon Withrow on 7/13/14.
//  Copyright (c) 2014 Brandon Withrow. All rights reserved.
//

#import "MCPYScalarSlider.h"
#import "MCStreamClient.h"
#import "MCExpandableTableModel.h"
#import "MCStreamRequest.h"
@implementation MCPYScalarSlider {
  UILabel *attrLabel;
  MCStreamRequest *currentRequest;
  
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
      UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
      [self addGestureRecognizer:pan];
      attrLabel = [[UILabel alloc] init];
      attrLabel.textColor = [UIColor whiteColor];
      [self addSubview:attrLabel];
      self.backgroundColor = [UIColor darkGrayColor];
    }
    return self;
}

- (void)setPyProperty:(NSString *)pyProperty {
  _pyProperty = pyProperty;
  attrLabel.text = pyProperty;
  [self setNeedsLayout];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  CGSize attrSize = [attrLabel sizeThatFits:self.bounds.size];
  CGRect attrFrame = CGRectZero;
  attrFrame.size = attrSize;
  attrFrame.origin = CGPointMake(10, 5);
  attrLabel.frame = attrFrame;
}

- (void)handlePan:(UIPanGestureRecognizer *)panGesture {
  if (panGesture.state == UIGestureRecognizerStateBegan) {
    self.backgroundColor = [UIColor blueColor];
  }
  if (panGesture.state == UIGestureRecognizerStateEnded ||
      panGesture.state == UIGestureRecognizerStateFailed ||
      panGesture.state == UIGestureRecognizerStateCancelled) {
    self.backgroundColor = [UIColor darkGrayColor];
  }
  float vel = [panGesture velocityInView:self].x * 0.01;
  if (panGesture.state == UIGestureRecognizerStateChanged &&
      self.pyProperty && self.dagObject && (currentRequest.status == MCStreamStatusFinished || currentRequest == nil) && (fabs(vel) > 0.05)) {
    
    NSString *message = [NSString stringWithFormat:@"bw.setValueRel('%@.%@', %f)", self.dagObject.title, self.pyProperty, vel];
    currentRequest = [[MCStreamRequest alloc] initWithMessage:message];
    [[MCStreamClient sharedClient] addRequestToQueue:currentRequest];
  }
}

@end
