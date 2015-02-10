//
//  AppController.m
//  Asterist
//
//  Created by Markus Amalthea Magnuson on 2014-12-27.
//  Copyright (c) 2014 Markus Amalthea Magnuson. All rights reserved.
//

#import "AppController.h"
#import "ViewController.h"
#import "IPFSController.h"

@implementation AppController

#pragma mark -
#pragma mark Application delegate methods

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [[[self viewController] loadingIndicator] startAnimation:self];

    NSString *executablesPath = [[[NSBundle mainBundle] executablePath] stringByDeletingLastPathComponent];
    [self setExecutablesPath:executablesPath];
    NSLog(@"Executables path is %@", executablesPath);

    [self launchIpfs:@[@"daemon"]];
}

- (void)watchPid:(NSInteger)pid {
    if ([[self waitForPid] isRunning]) {
        [[self waitForPid] terminate];
        [[self waitForPid] waitUntilExit];
    }

    [self setWaitForPid:[NSTask launchedTaskWithLaunchPath:[[self executablesPath] stringByAppendingPathComponent:@"asterist_wait_pid.py"]
                                                 arguments:@[[NSString stringWithFormat:@"%i", [[NSProcessInfo processInfo] processIdentifier]], // Current process pid.
                                                             [NSString stringWithFormat:@"%li", pid] // The newly spawned process pid.
                                                             ]]];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

#pragma mark -
#pragma mark IPFS daemon

// This will only be called if launch the ipfs daemon returns an error that ipfs
// is not yet initialized.
- (void)setupIpfs {
    NSLog(@"Setting up ipfs");

    NSTask *initIpfsTask = [NSTask launchedTaskWithLaunchPath:[[self ipfsDaemon] launchPath]
                                                    arguments:@[@"init"]];
    [initIpfsTask waitUntilExit];

    if ([initIpfsTask terminationStatus] != 0) {
        NSLog(@"Could not initialize ipfs, aborting");
        [NSApp terminate:nil];
    }
    else {
        NSLog(@"ipfs successfully initialized, continuing");
    }

    [self launchIpfs:@[@"daemon"]];
}

- (void)launchIpfs:(NSArray *)arguments {
    NSLog(@"Launching ipfs");

    if ([[self ipfsDaemon] isRunning]) {
        [[self ipfsDaemon] terminate];
        [[self ipfsDaemon] waitUntilExit];
    }

    // We need to reallocate/init the task, since an NSTask can only be run once.
    [self setIpfsDaemon:[[NSTask alloc] init]];
    [[self ipfsDaemon] setLaunchPath:[[self executablesPath] stringByAppendingPathComponent:@"ipfs"]];
    [[self ipfsDaemon] setArguments:arguments];

    NSPipe *pipe = [NSPipe pipe];

    [[self ipfsDaemon] setStandardOutput:pipe];
    [[self ipfsDaemon] setStandardError:pipe];

    NSFileHandle *outFile = [pipe fileHandleForReading];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ipfsDaemonDataAvailable:)
                                                 name:NSFileHandleDataAvailableNotification
                                               object:outFile];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ipfsDaemonDidTerminate:)
                                                 name:NSTaskDidTerminateNotification
                                               object:[self ipfsDaemon]];

    [[self ipfsDaemon] launch];

    NSLog(@"ipfs daemon started with pid %i", [[self ipfsDaemon] processIdentifier]);

    // Watch the new process and terminate it if Asterist does.
    [self watchPid:[[self ipfsDaemon] processIdentifier]];

    [outFile waitForDataInBackgroundAndNotify];
}

- (void)ipfsDaemonDataAvailable:(NSNotification *)notification {
    NSFileHandle *fileHandle = (NSFileHandle *)[notification object];
    NSData *data = [fileHandle availableData];

    if ([data length]) {
        NSString *outputString = [[NSString alloc] initWithData:data
                                                       encoding:NSUTF8StringEncoding];
        NSLog(@"Received data from task:");
        NSLog(@"%@", outputString);

        if ([outputString containsString:@"ipfs not initialized"]) {
            [self setupIpfs];
        }
        else if ([outputString containsString:@"server listening"]) {
            NSLog(@"Everything is running");
            [self.viewController.loadingIndicator stopAnimation:self];
            [[[self viewController] loadingTextField] setHidden:YES];
            [[[self viewController] tabView] setHidden:NO];
            [[self ipfsController] startUpdateTimer];
        }
    }

    [fileHandle waitForDataInBackgroundAndNotify];
}

- (void)ipfsDaemonDidTerminate:(NSNotification *)notification {
    NSTask *task = (NSTask *)[notification object];
    NSLog(@"The ipfs demon with pid %d terminated with exit status %i", [task processIdentifier], [task terminationStatus]);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
