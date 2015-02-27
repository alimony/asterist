//
//  IPFSPeer.m
//  Asterist
//
//  Created by Markus Amalthea Magnuson on 2015-02-03.
//  Copyright (c) 2015 Markus Amalthea Magnuson. All rights reserved.
//

#import "IPFSPeer.h"

@implementation IPFSPeer

// This method will take a string like this:
// "/ip4/123.456.789.123/tcp/5001/ipfs/QmSabcSGcabcZQJzRaabc95WabcSFmabcdDWabcXaHabcz"
// And split into its parts and make a new IPFSPeer object.
+ (IPFSPeer *)peerFromString:(NSString *)peerString {
    IPFSPeer *newPeer = [[self alloc] init];

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

    return newPeer;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<IPFSPeer: %@>", [self peerId]];
}

@end
