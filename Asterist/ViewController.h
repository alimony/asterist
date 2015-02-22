//
//  ViewController.h
//  Asterist
//
//  Created by Markus Amalthea Magnuson on 2014-12-27.
//  Copyright (c) 2014 Markus Amalthea Magnuson. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class IPFSController;

@interface ViewController : NSViewController <NSTabViewDelegate>

- (void)updateViewForLabel:(NSString *)label;

@property (weak) IBOutlet IPFSController *ipfsController;

@property (weak) IBOutlet NSTabView *tabView;
@property (weak) IBOutlet NSProgressIndicator *loadingIndicator;
@property (weak) IBOutlet NSTextField *loadingTextField;

// Home
@property (weak) IBOutlet NSTextField *peerIdField;
@property (weak) IBOutlet NSTextField *locationField;
@property (weak) IBOutlet NSTextField *agentVersionField;
@property (weak) IBOutlet NSTextField *protocolVersionField;
@property (weak) IBOutlet NSTextField *publicKeyField;

// Connections
@property (weak) IBOutlet NSTableView *swarmTable;

// Files
@property (weak) IBOutlet NSTabView *filesTabView;
@property (weak) IBOutlet NSTableView *pinnedFilesTable;
@property (weak) IBOutlet NSTableView *localFilesTable;

// Config
@property IBOutlet NSTextView *configTextView;

@end
