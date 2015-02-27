//
//  IPFSController.m
//  Asterist
//
//  Created by Markus Amalthea Magnuson on 2015-02-03.
//  Copyright (c) 2015 Markus Amalthea Magnuson. All rights reserved.
//

#import <AFNetworking.h>
#import "IPFSController.h"
#import "IPFSObject.h"
#import "IPFSPeer.h"

@implementation IPFSController

- (instancetype)init {
    if (self = [super init]) {
        [self setApiAddress:nil];
        [self setHttpManager:[AFHTTPRequestOperationManager manager]];
    }

    return self;
}

// This is a common method for sending an HTTP request to the IPFS daemon. It is
// passed a callback block that is executed on success, while errors are handled
// by a common handler. The reason for having this in a separate method is to
// have a clear place for code that should run for all commands.
- (void)daemonCommand:(NSString *)path successCallback:(void (^)(AFHTTPRequestOperation *operation, id responseObject))callbackBlock {
    if (![self apiAddress]) {
        NSLog(@"Cannot send command to daemon since IPFS controller has no API address");
        return;
    }

    NSString *url = [NSString stringWithFormat:@"%@%@", [self apiAddress], path];

    NSLog(@"Calling daemon: %@", url);

    [[self httpManager] GET:url parameters:nil success:callbackBlock failure:
    ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}

#pragma mark -
#pragma mark Home

// Get local user data such as peer ID, agent/protocol versions, etc.
- (void)daemonGetId {
    [self daemonCommand:@"/api/v0/id" successCallback:
    ^(AFHTTPRequestOperation *operation, id responseObject) {
        [self setPeerId:responseObject[@"ID"]];
        [self setLocation:@"Unknown"]; // TODO: Where do we get location from?
        [self setAgentVersion:responseObject[@"AgentVersion"]];
        [self setProtocolVersion:responseObject[@"ProtocolVersion"]];
        [self setPublicKey:responseObject[@"PublicKey"]];

        NSArray *networkAddresses = responseObject[@"Addresses"];
        if ([networkAddresses count] > 0) {
            NSMutableArray *addedAddresses = [NSMutableArray array];

            // These are peers like any others, except they point at ourselves.
            for (NSString *peerString in networkAddresses) {
                [addedAddresses addObject:[IPFSPeer peerFromString:peerString]];
            }

            NSLog(@"All local network addresses: %@", addedAddresses);

            [self setNetworkAddresses:addedAddresses];
        }
    }];
}

#pragma mark -
#pragma mark Connections

// Get the current list of peers in the swarm.
- (void)daemonGetSwarm {
    [self daemonCommand:@"/api/v0/swarm/peers" successCallback:
    ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *strings = responseObject[@"Strings"];

        if ([strings count] > 0) {
            NSMutableArray *addedPeers = [NSMutableArray array];

            // We get back an array of strings.
            for (NSString *peerString in strings) {
                [addedPeers addObject:[IPFSPeer peerFromString:peerString]];
            }
            
            NSLog(@"Current peers in swarm: %@", addedPeers);
            
            [self setSwarm:addedPeers];
        }
    }];
}

- (void)startSwarmUpdateTimer {
    NSLog(@"Starting connections view update timer");
    [self stopSwarmUpdateTimer];
    [self setUpdateSwarmTimer:[NSTimer scheduledTimerWithTimeInterval:2.0
                                                               target:self
                                                             selector:@selector(daemonGetSwarm)
                                                             userInfo:nil
                                                              repeats:YES]];
}

- (void)stopSwarmUpdateTimer {
    if ([self updateSwarmTimer]) {
        NSLog(@"Stopping connections view update timer");
        if ([[self updateSwarmTimer] isValid]) {
            [[self updateSwarmTimer] invalidate];
        }
        [self setUpdateSwarmTimer:nil];
    }
}

#pragma mark -
#pragma mark Files

// Get a list of pinned files, in direct or recursive mode. This is a "private"
// method that in turn is called by a couple of public methods below so that the
// recursive flag won't have to be passed all the time. Explicit method names is
// better.
- (void)_daemonGetPinnedFiles:(BOOL)recursive {
    NSString *requestPath = @"/api/v0/pin/ls";

    if (recursive) {
        requestPath = @"/api/v0/pin/ls?type=recursive";
    }

    [self daemonCommand:requestPath successCallback:
     ^(AFHTTPRequestOperation *operation, id responseObject) {
         NSArray *keys = responseObject[@"Keys"];

         if ([keys count] > 0) {
             NSMutableArray *addedObjects = [NSMutableArray array];

             for (NSString *objectId in keys) {
                 IPFSObject *newObject = [[IPFSObject alloc] init];
                 [newObject setObjectId:objectId];
                 [addedObjects addObject:newObject];
             }

             if (recursive) {
                 NSLog(@"All local files: %@", addedObjects);
                 [self setLocalFiles:addedObjects];
             }
             else {
                 NSLog(@"Pinned files: %@", addedObjects);
                 [self setPinnedFiles:addedObjects];
             }
         }
     }];
}

// Get a list of pinned files.
- (void)daemonGetPinnedFiles {
    [self _daemonGetPinnedFiles:NO];
}

// Get a list of all local files.
- (void)daemonGetLocalFiles {
    [self _daemonGetPinnedFiles:YES];
}

#pragma mark -
#pragma mark Config

// Get the current configuration and display it as raw JSON in a text field.
- (void)daemonGetConfig {
    // TODO: Something smarter than...
    [[self httpManager] setResponseSerializer:[AFHTTPResponseSerializer serializer]];

    [self daemonCommand:@"/api/v0/config/show" successCallback:
    ^(AFHTTPRequestOperation *operation, id responseObject) {
        // TODO: Why is this not returned by ipfs as e.g. JSON?
        NSString *responseString = [[NSString alloc] initWithData:responseObject
                                                         encoding:NSUTF8StringEncoding];

        [self setConfigString:responseString];
    }];

    // TODO: ...and then:
    [[self httpManager] setResponseSerializer:[AFJSONResponseSerializer serializer]];
}

@end
