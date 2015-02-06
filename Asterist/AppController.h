//
//  AppController
//  Asterist
//
//  Created by Markus Amalthea Magnuson on 2014-12-27.
//  Copyright (c) 2014 Markus Amalthea Magnuson. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class IPFSController, ViewController;

@interface AppController : NSObject <NSApplicationDelegate>

@property (weak) IBOutlet NSWindow *mainWindow;
@property (weak) IBOutlet IPFSController *ipfsController;
@property (weak) IBOutlet ViewController *viewController;

// We have two external processes. One is the ipfs daemon and the other a small
// script that waits for Asterist to die (on purpose or accidentally) and then
// kills the ipfs daemon as well.
@property NSString *executablesPath;
@property NSTask *ipfsDaemon;
@property NSTask *waitForPid;

@end
