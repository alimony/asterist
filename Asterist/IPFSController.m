//
//  IPFSController.m
//  Asterist
//
//  Created by Markus Amalthea Magnuson on 2015-02-03.
//  Copyright (c) 2015 Markus Amalthea Magnuson. All rights reserved.
//

#import <AFNetworking.h>
#import "IPFSController.h"
#import "IPFSPeer.h"

@implementation IPFSController

- (instancetype)init {
    if (self = [super init]) {
        [self setHttpManager:[AFHTTPRequestOperationManager manager]];
    }

    return self;
}

// This is a common method for sending an HTTP request to the IPFS daemon. It is
// passed a callback block that is executed on success, while errors are handled
// by a common handler. The reason for having this in a separate method is to
// have a clear place for code that should run for all commands.
- (void)daemonCommand:(NSString *)url successCallback:(void (^)(AFHTTPRequestOperation *operation, id responseObject))callbackBlock {
    [[self httpManager] GET:url parameters:nil success:callbackBlock failure:
    ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}

// Get the current list of peers in the swarm.
- (void)daemonGetSwarm {
    [self daemonCommand:@"http://localhost:5001/api/v0/swarm/peers" successCallback:
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
                    newPeer.ipProtocolVersion = @6;
                }
                else {
                    newPeer.ipProtocolVersion = @4;
                }

                newPeer.host = parts[2];
                newPeer.networkProtocol = parts[3];
                newPeer.port = @([parts[4] integerValue]);
                // For now, skip parts[5]: "ipfs"
                newPeer.peerId = parts[6];

                [addedPeers addObject:newPeer];
            }
            
            NSLog(@"Adding peers to swarm: %@", addedPeers);
            
            [self setSwarm:addedPeers];
        }
    }];
}

@end
