//
//  ViewController.h
//  mConnect
//
//  Created by Brandon Withrow on 7/9/14.
//  Copyright (c) 2014 Brandon Withrow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
- (id)initWithListCommand:(NSString *)pyList;

@property (nonatomic, assign) BOOL selectOnly;
@end
