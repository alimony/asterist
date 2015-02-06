//
//  IPFSPeer.h
//  Asterist
//
//  Created by Markus Amalthea Magnuson on 2015-02-03.
//  Copyright (c) 2015 Markus Amalthea Magnuson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IPFSPeer : NSObject

@property NSNumber *ipProtocolVersion;
@property NSHost *host;
@property NSString *networkProtocol;
@property NSNumber *port;
@property NSString *peerId;

@end
