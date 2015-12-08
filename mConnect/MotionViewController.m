//
//  MotionViewController.m
//  mConnect
//
//  Created by Brandon Withrow on 8/20/14.
//  Copyright (c) 2014 Brandon Withrow. All rights reserved.
//

#import "MotionViewController.h"
#import <CoreMotion/CoreMotion.h>
#import "MCStreamClient.h"
#import "MCKnobView.h"
#import "MCThreeAxisControl.h"
#import "MCPropertyControl.h"

static const CGFloat channelBoxWidth = 250.f;

@interface MotionViewController ()
@property (nonatomic, strong) NSDictionary *cbAttributes;
@end

@implementation MotionViewController {
  MCThreeAxisControl *axisControl_;
  MCStreamRequest *moveRequest_;
  UIView *attributesContainer_;
  NSMutableArray *attrViews_;
  NSMutableDictionary *propertyUpdates_;
  NSString *currentObject_;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  attrViews_ = [NSMutableArray array];
  propertyUpdates_ = [NSMutableDictionary dictionary];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectionChanges:) name:kMayaSelectionChangedNotification object:NULL];
  self.view.backgroundColor = [UIColor mayaBackgroundColor];
  
  CGSize circleSize = CGSizeMake(250, 250);
  axisControl_ = [[MCThreeAxisControl alloc] initWithFrame:CGRectFramedCenteredInRect(self.view.bounds, circleSize, YES)];
  [axisControl_ addTarget:self action:@selector(knobChanged:) forControlEvents:UIControlEventValueChanged];
  [self.view addSubview:axisControl_];
  
  attributesContainer_ = [[UIView alloc] initWithFrame:CGRectZero];
  [self.view addSubview:attributesContainer_];
  
  
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  [self _layoutAttributes];
  [self _layoutAxisControls];
}

- (void)_layoutAxisControls {
  CGRect bounds = self.view.bounds;
  bounds.size.width -= channelBoxWidth;
  axisControl_.frame = CGRectFramedCenteredInRect(bounds, axisControl_.bounds.size, YES);
}

- (void)_layoutAttributes {
  attributesContainer_.hidden = attrViews_.count == 0;
  if (!attrViews_.count) {
    return;
  }
  CGSize itemSize = CGSizeMake(channelBoxWidth, CLAMP(self.view.bounds.size.height / attrViews_.count, 20, 40));
  
  CGSize containerSize = CGSizeMake(channelBoxWidth, itemSize.height * attrViews_.count);
  attributesContainer_.frame = CGRectFramedRightInRect(self.view.bounds, containerSize, 0, YES);
  
  CGRect prevFrame = CGRectMake(0, 0, itemSize.width, itemSize.height);
  for (MCPropertyControl *control in attrViews_) {
    control.frame = prevFrame;
    prevFrame.origin.y += prevFrame.size.height;
  }
}

- (void)setCbAttributes:(NSDictionary *)cbAttributes {
  [attrViews_ makeObjectsPerformSelector:@selector(removeFromSuperview)];
  [attrViews_ removeAllObjects];
  _cbAttributes = cbAttributes;
  for (NSString *attr in cbAttributes.allKeys) {
    MCPropertyControl *prop = [[MCPropertyControl alloc] initWithFrame:CGRectZero];
    prop.niceName = attr;
    prop.absoluteValue = [[cbAttributes valueForKey:attr] floatValue];
    prop.propName = prop.niceName;
    [prop addTarget:self action:@selector(attributeChanged:) forControlEvents:UIControlEventValueChanged];
    [attributesContainer_ addSubview:prop];
    [attrViews_ addObject:prop];
  }
  [self _layoutAttributes];
}

#pragma mark - Attribute Responders

- (void)attributeChanged:(MCPropertyControl *)sender {
  [self updateAttribue:sender.propName toValue:@(sender.absoluteValue)];
}

- (void)updateAttribue:(NSString *)attr toValue:(NSNumber *)value {
  BOOL currentlyUpdating = [propertyUpdates_ objectForKey:attr] != nil;
  [propertyUpdates_ setObject:value forKey:attr];
  if (!currentlyUpdating) {
    NSString *pyCommand = [NSString stringWithFormat:@"cmds.setAttr(\"%@.%@\", %f)", currentObject_, attr, value.floatValue];
    __weak typeof(self) weakSelf = self;
    moveRequest_ = [[MCStreamClient sharedClient] sendPyCommand:pyCommand
                                                 withCompletion:^(NSString *returnString) {
                                                   NSLog(@"%@", returnString);
                                                   __strong typeof(self) strongSelf = weakSelf;
                                                   [strongSelf attributeUpdated:attr toValue:value];
                                                 } withFailure:^{
                                                   __strong typeof(self) strongSelf = weakSelf;
                                                   [strongSelf attributeUpdated:attr toValue:value];
                                                 }];
  }
}

- (void)attributeUpdated:(NSString *)attribute toValue:(NSNumber *)value {
  NSNumber *storeValue = [propertyUpdates_ objectForKey:attribute];
  [propertyUpdates_ removeObjectForKey:attribute];
  if (![value isEqual:storeValue]) {
    // Further Updates Required.
    [self updateAttribue:attribute toValue:storeValue];
  }
}

#pragma Mark - Axis Knob Responders

- (void)knobChanged:(MCThreeAxisControl *)sender {
  [self _updateForKnob];
}

- (void)_updateForKnob {
  GLKVector3 relatives = [axisControl_ rotationsRelative];
  if (moveRequest_ &&
      (moveRequest_.status == MCStreamStatusFailed ||
       moveRequest_.status == MCStreamStatusFinished)) {
        moveRequest_ = nil;
  }
  if (relatives.x + relatives.y + relatives.z != 0 && !moveRequest_) {
    GLKVector3 relatives = [axisControl_ rotationsRelative];
    [axisControl_ resetRelativeAngles];
    NSString *pyCommand = [NSString stringWithFormat:@"cmds.rotate('%f', '%f', '%f', r=True, os=True, eu=True)", relatives.x, relatives.y, relatives.z];

    __weak typeof(self) weakSelf = self;
    NSLog(@"Move Queued");
    moveRequest_ = [[MCStreamClient sharedClient] sendPyCommand:pyCommand
                                                 withCompletion:^(NSString *returnString) {
                                                   __strong typeof(self) strongSelf = weakSelf;
                                                   [strongSelf _updateFinished];
                                                 } withFailure:^{
                                                   __strong typeof(self) strongSelf = weakSelf;
                                                   [strongSelf _updateFinished];
                                                 }];
  }
}

- (void)_updateFinished {
  moveRequest_ = nil;
  [self _updateForKnob];
}

#pragma Mark - Selection Change Notification
- (void)selectionChanges:(NSNotification *)notif {
  if ([[notif.userInfo objectForKey:@"data"] isKindOfClass:[NSArray class]]) {
    NSArray *selection = [notif.userInfo objectForKey:@"data"];
    if (selection.count) {
      NSDictionary *object = selection.firstObject;
      NSString *objectName = object.allKeys.firstObject;
      currentObject_= objectName;
      NSDictionary *attrs = [object valueForKey:objectName];
      self.cbAttributes = attrs;
//      xRot = [[attrs valueForKey:@"rotateX"] floatValue];
//      yRot = [[attrs valueForKey:@"rotateY"] floatValue];
//      zRot = [[attrs valueForKey:@"rotateZ"] floatValue];
//      xKnob.rotation = xRot;
//      yKnob.rotation = yRot;
//      zKnob.rotation = zRot;
    } else {
      // No Selection
      [propertyUpdates_ removeAllObjects];
      currentObject_ = nil;
      self.cbAttributes = nil;
    }
    
  }
}

@end
