//
//  AppController.m
//  Asterist
//
//  Created by Markus Amalthea Magnuson on 2014-12-27.
//  Copyright (c) 2014 Markus Amalthea Magnuson. All rights reserved.
//

#import <WebKit/WebView.h>
#import "AppController.h"
#import "ViewController.h"

@implementation AppController

#pragma mark -
#pragma mark Application delegate methods

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [[[self mainViewController] spinner] startAnimation:self];
    [[[self mainViewController] spinnerText] setHidden:NO];

    // This is where all our executables (go, ipfs, node) will be launched from.
    [self setExecutablesPath:[[[NSBundle mainBundle] executablePath] stringByDeletingLastPathComponent]];

    [self launchIpfs:@[@"daemon"]];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    NSLog(@"Terminating gulp");
    [[self webInterface] interrupt];
    NSLog(@"Terminating ipfs");
    [[self ipfs] interrupt];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

#pragma mark -
#pragma mark IPFS backend

- (void)launchIpfs:(NSArray *)arguments {
    NSLog(@"Launching ipfs");

    [[[self mainViewController] spinnerText] setStringValue:@"Launching IPFS…"];

    [self initIpfs];
    [[self ipfs] setArguments:arguments];

    // TODO: Check if an ipfs process is already running.
    [self createPipeForTask:[self ipfs]];
}

- (void)initIpfs {
    NSString *ipfsPath = [[self executablesPath] stringByAppendingPathComponent:@"ipfs"];
    NSLog(@"ipfs path is %@", ipfsPath);

    [self setIpfs:[[NSTask alloc] init]];

    [[self ipfs] setLaunchPath:ipfsPath];
}

- (void)setupIpfs {
    NSLog(@"Setting up ipfs");

    [[[self mainViewController] spinnerText] setStringValue:@"Setting up IPFS…"];

    NSTask *initIpfsTask = [NSTask launchedTaskWithLaunchPath:[[self ipfs] launchPath]
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

#pragma mark -
#pragma mark Web interface

- (void)initWebInterface {
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *webInterfacePath = [resourcePath stringByAppendingPathComponent:@"ipfs-webui/node_modules/.bin/gulp"];
    NSLog(@"gulp path is %@", webInterfacePath);

    [self setWebInterface:[[NSTask alloc] init]];

    [[self webInterface] setCurrentDirectoryPath:[resourcePath stringByAppendingPathComponent:@"ipfs-webui"]];
    [[self webInterface] setLaunchPath:webInterfacePath];

    // Gulp needs to run our own copy of node, so put it first in PATH.
    NSDictionary *env = [NSDictionary dictionaryWithObjects:@[[self executablesPath]]
                                                    forKeys:@[@"PATH"]];
    [[self webInterface] setEnvironment:env];
}

- (void)launchWebInterface {
    NSLog(@"Launching web interface");

    [[[self mainViewController] spinnerText] setStringValue:@"Loading interface…"];

    [self initWebInterface];

    // TODO: Check if a web interface gulp process is already running
    [self createPipeForTask:[self webInterface]];
}

- (void)displayWebInterface {
    // TODO: Launch gulp on a random high port instead, to avoid collisions.
    [[[self mainViewController] webView] setMainFrameURL:@"http://localhost:8000"];
}

#pragma mark -
#pragma mark Task handlers

- (void)createPipeForTask:(NSTask *)task {
    // This is just for informational purposes.
    NSString *taskName = [[task launchPath] lastPathComponent];

    NSPipe *pipe = [NSPipe pipe];

    [task setStandardOutput:pipe];
    [task setStandardError:pipe];

    NSFileHandle *outFile = [pipe fileHandleForReading];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(taskData:)
                                                 name:NSFileHandleDataAvailableNotification
                                               object:outFile];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(taskTerminated:)
                                                 name:NSTaskDidTerminateNotification
                                               object:task];

    NSLog(@"Launching %@", taskName);

    [task launch];

    NSLog(@"%@ started with pid %i", taskName, [task processIdentifier]);

    [outFile waitForDataInBackgroundAndNotify];
}

- (void)taskData:(NSNotification *)notification {
    NSLog(@"Received data from task");

    NSFileHandle *fileHandle = (NSFileHandle *)[notification object];
    NSData *data = [fileHandle availableData];

    if ([data length]) {
        NSString *outputString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", outputString);

        if ([outputString containsString:@"ipfs not initialized"]) {
            [self setupIpfs];
        }
        else if ([outputString containsString:@"daemon listening"]) {
            [self launchWebInterface];
        }
        else if ([outputString containsString:@"Using gulpfile"]) {
            NSLog(@"Displaying web interface");
            [self setWebInterfaceTimer:[NSTimer scheduledTimerWithTimeInterval:2.0
                                                                        target:self
                                                                      selector:@selector(displayWebInterface)
                                                                      userInfo:nil
                                                                       repeats:YES]];
        }
    }
}

- (void)taskTerminated:(NSNotification *)notification {
    NSTask *task = (NSTask *)[notification object];
    NSLog(@"%@ (pid %d) terminated with exit status %i",
          [[task launchPath] lastPathComponent], [task processIdentifier], [task terminationStatus]);
    // TODO: This needs to remove only observation of the ipfs process, probably
    // by having two dedicated observers instead of using the app delegate.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark Web view delegate methods

- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame {
    NSLog(@"Started loading web view");
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    NSLog(@"Finished loading web view");
    [[self webInterfaceTimer] invalidate];
    [[[self mainViewController] spinner] stopAnimation:self];
    [[[self mainViewController] spinnerText] setHidden:YES];
}

@end
