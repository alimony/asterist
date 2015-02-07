//
//  NSStringValueTransformer.m
//  Asterist
//
//  Created by Markus Amalthea Magnuson on 2015-02-07.
//  Copyright (c) 2015 Markus Amalthea Magnuson. All rights reserved.
//

#import "NSStringValueTransformer.h"

@implementation NSStringValueTransformer

+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    return [value stringValue];
}

@end
