//
//  MCStreamClient.h
//  mConnect
//
//  Created by Brandon Withrow on 7/9/14.
//  Copyright (c) 2014 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *kMayaSelectionChangedNotification = @"mcSelectionChanged";

@class MCStreamRequest;

@interface MCStreamClient : NSObject <NSStreamDelegate, UIAlertViewDelegate>

+ (MCStreamClient *)sharedClient;

- (void)startConnectionWithHost:(NSString *)host andPort:(int)port;

- (void)addRequestToQueue:(MCStreamRequest *)request;

- (MCStreamRequest *)sendPyCommand:(NSString *)command
                    withCompletion:(void (^)(NSString *))completion
                       withFailure:(void (^)(void))failure;

- (MCStreamRequest *)getJSONFromPyCommand:(NSString *)command
                           withCompletion:(void (^)(id JSONObject))completion
                              withFailure:(void (^)(void))failure;

- (void)selectObject:(NSString *)object;

@end
