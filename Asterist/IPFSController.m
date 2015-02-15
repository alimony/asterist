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

            // We get back an array of strings looking like this:
            // "/ip4/123.456.789.123/tcp/5001/ipfs/QmSabcSGcabcZQJzRaabc95WabcSFmabcdDWabcXaHabcz"
            // Split into its parts and make IPFSPeer objects.
            for (NSString *peerString in strings) {
                IPFSPeer *newPeer = [[IPFSPeer alloc] init];
                NSArray *parts = [peerString componentsSeparatedByString:@"/"];

                if ([parts[1] isEqualToString:@"ip6"]) {
                    [newPeer setIpProtocolVersion:@6];
                }
                else {
                    [newPeer setIpProtocolVersion:@4];
                }

                [newPeer setHost:parts[2]];
                [newPeer setNetworkProtocol:parts[3]];
                [newPeer setPort:@([parts[4] integerValue])];
                // For now, skip parts[5]: "ipfs"
                [newPeer setPeerId:parts[6]];

                [addedPeers addObject:newPeer];
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

// Get a list of pinned files.
- (void)daemonGetPinnedFiles {
    [self daemonCommand:@"/api/v0/pin/ls" successCallback:
    ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *keys = responseObject[@"Keys"];
        
        if ([keys count] > 0) {
            NSMutableArray *addedObjects = [NSMutableArray array];
            
            for (NSString *objectId in keys) {
                IPFSObject *newObject = [[IPFSObject alloc] init];
                [newObject setObjectId:objectId];
                [addedObjects addObject:newObject];
            }
            
            NSLog(@"Pinned files: %@", addedObjects);
            
            [self setPinnedFiles:addedObjects];
        }
    }];
}

// Get a list of all local files.
- (void)daemonGetLocalFiles {
    // TODO: Something smarter than...
    [[self httpManager] setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    
    [self daemonCommand:@"/api/v0/refs/local" successCallback:
    ^(AFHTTPRequestOperation *operation, id responseObject) {
        // TODO: Why are these not returned by ipfs as e.g. JSON?
        NSString *responseString = [[NSString alloc] initWithData:responseObject
                                                         encoding:NSUTF8StringEncoding];
         
        NSArray *objectIds = [responseString componentsSeparatedByString:@"\n"];
         
        if ([objectIds count] > 0) {
            NSMutableArray *addedObjects = [NSMutableArray array];
             
            for (NSString *objectId in objectIds) {
                if ([objectId length] > 0) {
                    IPFSObject *newObject = [[IPFSObject alloc] init];
                    [newObject setObjectId:objectId];
                    [addedObjects addObject:newObject];
                }
            }
             
            NSLog(@"All local files: %@", addedObjects);
             
            [self setLocalFiles:addedObjects];
        }
    }];
    
    // TODO: ...and then:
    [[self httpManager] setResponseSerializer:[AFJSONResponseSerializer serializer]];
}

@end
