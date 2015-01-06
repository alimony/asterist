//
//  AppController
//  Asterist
//
//  Created by Markus Amalthea Magnuson on 2014-12-27.
//  Copyright (c) 2014 Markus Amalthea Magnuson. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ViewController;

@interface AppController : NSObject <NSApplicationDelegate>

@property (weak) IBOutlet ViewController *mainViewController;

@property NSString *executablesPath;
@property NSTask *ipfs;
@property NSTask *webInterface;
@property NSTimer *webInterfaceTimer;

@end
