//
//  IPFSController.h
//  Asterist
//
//  Created by Markus Amalthea Magnuson on 2015-02-03.
//  Copyright (c) 2015 Markus Amalthea Magnuson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFHTTPRequestOperationManager;

@interface IPFSController : NSObject

- (void)startUpdateTimer;
- (void)stopUpdateTimer;
- (void)updateViews;
- (void)daemonGetSwarm;

@property NSTimer *updateTimer;
@property AFHTTPRequestOperationManager *httpManager;
@property NSArray *swarm;

@end
