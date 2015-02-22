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

@property AFHTTPRequestOperationManager *httpManager;

// This is where API calls should be made, i.e. where the daemon is listening.
// We will fetch this value from the daemon config on launch.
@property NSString *apiAddress;

// Home
- (void)daemonGetId;
@property NSString *peerId;
@property NSString *location;
@property NSString *agentVersion;
@property NSString *protocolVersion;
@property NSString *publicKey;

// Connections
- (void)daemonGetSwarm;
- (void)startSwarmUpdateTimer;
- (void)stopSwarmUpdateTimer;
@property NSArray *swarm;
@property NSTimer *updateSwarmTimer;

// Files
- (void)daemonGetPinnedFiles;
- (void)daemonGetLocalFiles;
@property NSArray *pinnedFiles;
@property NSArray *localFiles;

// Config
- (void)daemonGetConfig;
@property NSString *configString;

@end
