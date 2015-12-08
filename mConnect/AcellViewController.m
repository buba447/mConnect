//
//  AcellViewController.m
//  mConnect
//
//  Created by Brandon Withrow on 7/29/15.
//  Copyright (c) 2015 Brandon Withrow. All rights reserved.
//

#import "AcellViewController.h"
#import <CoreMotion/CoreMotion.h>

#import "GraphView.h"

@interface AcellViewController ()
@property (nonatomic, strong) CMMotionManager *motionManager;

@end

@implementation AcellViewController {
  CGFloat xRot_;
  CGFloat yRot_;
  CGFloat zRot_;
  CGFloat xTrans_;
  CGFloat yTrans_;
  CGFloat zTrans_;
  NSTimeInterval lastTimeStamp_;
  GraphView *graphX;
  GraphView *graphY;
  GraphView *graphZ;
}

- (void)viewDidLoad {
    [super viewDidLoad];
  graphX = [[GraphView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
  [self.view addSubview:graphX];
  
  graphY = [[GraphView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
  [self.view addSubview:graphY];
  
  graphZ = [[GraphView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
  [self.view addSubview:graphZ];
  
  [self.onSwitch addTarget:self action:@selector(_onSwitchToggled:) forControlEvents:UIControlEventValueChanged];
  [self.calibrateButton addTarget:self action:@selector(_calibrateMotionValues) forControlEvents:UIControlEventTouchUpInside];
  self.motionManager = [[CMMotionManager alloc] init];
  self.motionManager.deviceMotionUpdateInterval = 0.01;
  lastTimeStamp_ = 0;
  [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
    CGFloat timeElapsed = motion.timestamp - lastTimeStamp_;
    if (lastTimeStamp_ > 0) {
      CGFloat xDiff = round((RadiansToDegrees(motion.rotationRate.x) * timeElapsed) * 10) / 10.f;
      CGFloat yDiff = round((RadiansToDegrees(motion.rotationRate.y) * timeElapsed) * 10) / 10.f;
      CGFloat zDiff = round((RadiansToDegrees(motion.rotationRate.z) * timeElapsed) * 10) / 10.f;
      xRot_ += xDiff;
      yRot_ += yDiff;
      zRot_ += zDiff;
      xTrans_ += round(motion.userAcceleration.x * timeElapsed * self.slider1.value * 10) / 10.f;
      yTrans_ += round(motion.userAcceleration.y * timeElapsed * self.slider1.value * 10) / 10.f;
      zTrans_ += round(motion.userAcceleration.z * timeElapsed * self.slider1.value * 10) / 10.f;
      
      
      [graphX pushValueOntoStack:xRot_];
      [graphY pushValueOntoStack:yRot_];
      [graphZ pushValueOntoStack:zRot_];
    }
    lastTimeStamp_ = motion.timestamp;
  }];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillLayoutSubviews {
  [super viewWillLayoutSubviews];
  CGSize graphSize = CGSizeMake(self.view.bounds.size.width, 70);
  graphZ.frame = CGRectFramedBottomInRect(self.view.bounds, graphSize, 0, YES);
  graphY.frame = CGRectFramedBottomInRect(self.view.bounds, graphSize, graphSize.height, YES);
  graphX.frame = CGRectFramedBottomInRect(self.view.bounds, graphSize, graphSize.height * 2, YES);
}

- (void)_startMotionUpdates {
  
}

- (void)_calibrateMotionValues {
  yRot_ = 0;
  xRot_ = 0;
  zRot_ = 0;
  xTrans_ = 0;
  yTrans_ = 0;
  zTrans_ = 0;
}

- (void)_readMotionData {
  if (!self.onSwitch.on) {
    return;
  }
  

  self.xRotLabel.text = [NSString stringWithFormat:@"%.2f", xTrans_ ];
  self.yRotLabel.text = [NSString stringWithFormat:@"%.2f", yTrans_ ];
  self.zRotLabel.text = [NSString stringWithFormat:@"%.2f", zTrans_ ];
  
  NSMutableArray *rotationValues = [NSMutableArray arrayWithObjects:@(xRot_), @(yRot_), @(zRot_), nil];
  
  NSMutableArray *swappedValues = [NSMutableArray array];
  [swappedValues addObject:rotationValues[self.firstRotation.selectedSegmentIndex]];
  [swappedValues addObject:rotationValues[self.secondRotation.selectedSegmentIndex]];
  NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndex:self.firstRotation.selectedSegmentIndex];
  [indexSet addIndex:self.secondRotation.selectedSegmentIndex];
  [rotationValues removeObjectsAtIndexes:indexSet];
  [swappedValues addObject:rotationValues.firstObject];
  
//NSString *pyCommand = [NSString stringWithFormat:@"cmds.xform( t=(%f, %f, %f) )", xTrans_, yTrans_, zTrans_];
  NSString *pyCommand = [NSString stringWithFormat:@"cmds.xform( r=False, ro=(%f, %f, %f), t=(%f, %f, %f) )", [swappedValues[0] floatValue], [swappedValues[1] floatValue], [swappedValues[2] floatValue], xTrans_, yTrans_, zTrans_];

  __weak typeof(self) weakSelf = self;
  [[MCStreamClient sharedClient] sendPyCommand:pyCommand
                                withCompletion:^(NSString *returnString) {
                                  __strong typeof(self) strongSelf = weakSelf;
                                  [strongSelf performSelector:@selector(_readMotionData) withObject:NULL afterDelay:(4.f/60.f)];
                                } withFailure:NULL];
}

- (void)_setRotationOrder {
  
}

- (void)_onSwitchToggled:(UISwitch *)onSwitch {
  [self _readMotionData];
}

@end
