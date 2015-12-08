//
//  MCPYScalarSlider.h
//  mConnect
//
//  Created by Brandon Withrow on 7/13/14.
//  Copyright (c) 2014 Brandon Withrow. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MCDAGObject;

@interface MCPYScalarSlider : UIView
@property (nonatomic, strong) MCDAGObject *dagObject;
@property (nonatomic, strong) NSString *pyProperty;

@end
