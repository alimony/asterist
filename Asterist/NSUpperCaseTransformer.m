//
//  NSUpperCaseTransformer.m
//  Asterist
//
//  Created by Markus Amalthea Magnuson on 2015-02-07.
//  Copyright (c) 2015 Markus Amalthea Magnuson. All rights reserved.
//

#import "NSUpperCaseTransformer.h"

@implementation NSUpperCaseTransformer

+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    return [value uppercaseString];
}

@end
