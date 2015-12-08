//
//  ViewController.m
//  ClockGlitch
//
//  Created by Brandon Withrow on 8/9/15.
//  Copyright (c) 2015 Brandon Withrow. All rights reserved.
//

#import "ClockViewController.h"
#import "BWClockElement.h"
#import "BWDigitView.h"
#import "CGGeometryAdditions.h"

@interface ClockViewController ()

@end

@implementation ClockViewController {
  BWDigitView *digit0;
  BWDigitView *digit1;
  BWDigitView *digit2;
  BWDigitView *digit3;
  UISlider *phaseSlider_;
  UISlider *frequencySlider_;
  UISlider *onOffRatioSlider_;
  UIButton *flash22Button_;
  UIButton *randomNumberbutton_;
  UIView *dot1_;
  UIView *dot2_;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor blackColor];
  digit0 = [[BWDigitView alloc] initWithFrame:CGRectMake(40, 40, 70, 140)];
  [self.view addSubview:digit0];
  
  digit1 = [[BWDigitView alloc] initWithFrame:CGRectMake(40, 40, 70, 140)];
  [self.view addSubview:digit1];
  
  digit2 = [[BWDigitView alloc] initWithFrame:CGRectMake(40, 40, 70, 140)];
  [self.view addSubview:digit2];
  
  digit3 = [[BWDigitView alloc] initWithFrame:CGRectMake(40, 40, 70, 140)];
  [self.view addSubview:digit3];
  
  
  phaseSlider_ = [[UISlider alloc] initWithFrame:CGRectZero];
  phaseSlider_.minimumValue = 0;
  phaseSlider_.value = 0;
  phaseSlider_.maximumValue = 2.5;
  [phaseSlider_ addTarget:self action:@selector(_updateTiming) forControlEvents:UIControlEventValueChanged];
  [self.view addSubview:phaseSlider_];
  
  
  frequencySlider_ = [[UISlider alloc] initWithFrame:CGRectZero];
  frequencySlider_.minimumValue = 0;
  frequencySlider_.value = 0.1;
  frequencySlider_.maximumValue = 2;
  [frequencySlider_ addTarget:self action:@selector(_updateTiming) forControlEvents:UIControlEventValueChanged];
  [self.view addSubview:frequencySlider_];
  
  onOffRatioSlider_ = [[UISlider alloc] initWithFrame:CGRectZero];
  onOffRatioSlider_.minimumValue = 0.001;
  onOffRatioSlider_.value = 0.1;
  onOffRatioSlider_.maximumValue = 0.999;
  [onOffRatioSlider_ addTarget:self action:@selector(_updateTiming) forControlEvents:UIControlEventValueChanged];
  [self.view addSubview:onOffRatioSlider_];
  
  [self setDigits:8 two:8 three:8 four:8];
  
  flash22Button_ = [UIButton buttonWithType:UIButtonTypeCustom];
  [flash22Button_ setTitle:@"TWENTYTWO" forState:UIControlStateNormal];
  [flash22Button_ addTarget:self action:@selector(_flash22) forControlEvents:UIControlEventTouchDown];
  [flash22Button_ addTarget:self action:@selector(_resetTime) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:flash22Button_];
  
  randomNumberbutton_ = [UIButton buttonWithType:UIButtonTypeCustom];
  [randomNumberbutton_ setTitle:@"RANDO" forState:UIControlStateNormal];
  [randomNumberbutton_ addTarget:self action:@selector(_flashRandomNumber) forControlEvents:UIControlEventTouchDown];
  [randomNumberbutton_ addTarget:self action:@selector(_resetTime) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:randomNumberbutton_];
  
  dot1_ = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
  dot1_.layer.cornerRadius = 10;
  dot1_.backgroundColor = [UIColor redColor];
  [self.view addSubview:dot1_];
  dot2_ = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
  dot2_.layer.cornerRadius = 10;
  dot2_.backgroundColor = [UIColor redColor];
  [self.view addSubview:dot2_];
}

- (void)_flash22 {
  [self setDigits:10 two:10 three:2 four:2];
}

- (void)_flashRandomNumber {
  int a = arc4random() % 11;
  int b = arc4random() % 11;
  int c = arc4random() % 11;
  int d = arc4random() % 11;
  [self setDigits:a two:b three:c four:d];
}

- (void)_resetTime {
  [self setDigits:10 two:9 three:2 four:7];
}

- (void)setDigits:(NSInteger)one two:(NSInteger)two three:(NSInteger)three four:(NSInteger)four {
  if (one > 9) {
    [digit0 setAllOffOverride];
  } else {
    [digit0 resetOverride];
    digit0.faceValue = one;
  }
  
  if (two > 9) {
    [digit1 setAllOffOverride];
  } else {
    [digit1 resetOverride];
    digit1.faceValue = two;
  }
  
  if (three > 9) {
    [digit2 setAllOffOverride];
  } else {
    [digit2 resetOverride];
    digit2.faceValue = three;
  }
  
  if (four > 9) {
    [digit3 setAllOffOverride];
  } else {
    [digit3 resetOverride];
    digit3.faceValue = four;
  }
  
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  CGSize constraintSize = CGSizeMake((self.view.bounds.size.width / 3) - 20, 70);
  CGSize sliderSize = [onOffRatioSlider_ sizeThatFits:constraintSize];
  
  phaseSlider_.frame = CGRectFramedBottomLeftInRect(self.view.bounds, sliderSize, 10, 20, YES);
  
  frequencySlider_.frame = CGRectAttachedRightToRect(phaseSlider_.frame, sliderSize, 30, YES);
  
  onOffRatioSlider_.frame = CGRectAttachedRightToRect(frequencySlider_.frame, sliderSize, 20, YES);
  
  CGSize digitSize = CGSizeMake(130, 240);
  
  
  
  CGSize rectSize = CGSizeMake((digitSize.width * 2) + 70 , digitSize.height);
  
  CGRect leftRect = CGRectFramedLeftInRect(self.view.bounds, rectSize, 110, YES);
  CGRect rightRect = CGRectFramedRightInRect(self.view.bounds, rectSize, 110, YES);
  
  digit0.frame = CGRectFramedLeftInRect(leftRect, digitSize, 0, YES);
  digit1.frame = CGRectFramedRightInRect(leftRect, digitSize, 0, YES);
  digit2.frame = CGRectFramedLeftInRect(rightRect, digitSize, 0, YES);
  digit3.frame = CGRectFramedRightInRect(rightRect, digitSize, 0, YES);
  
  CGSize buttonSize = CGSizeMake(120, 44);
  flash22Button_.frame = CGRectAttachedTopToRect(onOffRatioSlider_.frame, buttonSize, 10, YES);
  randomNumberbutton_.frame = CGRectAttachedLeftToRect(flash22Button_.frame, buttonSize, 10, YES);
  
  CGRect midRect = CGRectFramedCenteredInRect(self.view.bounds, digitSize, YES);
  dot1_.frame = CGRectFramedTopInRect(midRect, dot1_.frame.size, 50, YES);
  dot2_.frame = CGRectFramedBottomInRect(midRect, dot1_.frame.size, 50, YES);
}

- (void)_updateTiming {
  digit0.frequency = frequencySlider_.value;
  digit0.phase = phaseSlider_.value;
  digit0.onOffRatio = onOffRatioSlider_.value;
  digit1.frequency = frequencySlider_.value;
  digit1.phase = phaseSlider_.value;
  digit1.onOffRatio = onOffRatioSlider_.value;
  digit2.frequency = frequencySlider_.value;
  digit2.phase = phaseSlider_.value;
  digit2.onOffRatio = onOffRatioSlider_.value;
  digit3.frequency = frequencySlider_.value;
  digit3.phase = phaseSlider_.value;
  digit3.onOffRatio = onOffRatioSlider_.value;
}
- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
