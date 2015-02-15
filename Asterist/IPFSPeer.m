//
//  IPFSPeer.m
//  Asterist
//
//  Created by Markus Amalthea Magnuson on 2015-02-03.
//  Copyright (c) 2015 Markus Amalthea Magnuson. All rights reserved.
//

#import "IPFSPeer.h"

@implementation IPFSPeer

- (NSString *)description {
    return [NSString stringWithFormat:@"<IPFSPeer: %@>", [self peerId]];
}

@end
