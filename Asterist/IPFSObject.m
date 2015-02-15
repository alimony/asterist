//
//  IPFSObject.m
//  Asterist
//
//  Created by Markus Amalthea Magnuson on 2015-02-15.
//  Copyright (c) 2015 Markus Amalthea Magnuson. All rights reserved.
//

#import "IPFSObject.h"

@implementation IPFSObject

- (NSString *)description {
    return [NSString stringWithFormat:@"<IPFSObject: %@>", [self objectId]];
}

@end
