//
//  AcellViewController.h
//  mConnect
//
//  Created by Brandon Withrow on 7/29/15.
//  Copyright (c) 2015 Brandon Withrow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AcellViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *calibrateButton;
@property (weak, nonatomic) IBOutlet UISlider *slider1;
@property (weak, nonatomic) IBOutlet UISwitch *onSwitch;
@property (weak, nonatomic) IBOutlet UILabel *xRotLabel;
@property (weak, nonatomic) IBOutlet UILabel *yRotLabel;
@property (weak, nonatomic) IBOutlet UILabel *zRotLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *firstRotation;
@property (weak, nonatomic) IBOutlet UISegmentedControl *secondRotation;

@end
