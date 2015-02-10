//
//  ViewController.m
//  Asterist
//
//  Created by Markus Amalthea Magnuson on 2014-12-27.
//  Copyright (c) 2014 Markus Amalthea Magnuson. All rights reserved.
//

#import "ViewController.h"
#import "IPFSController.h"

@implementation ViewController

// This method is called every time a tab is selected in the tab view.
- (void)tabView:(NSTabView *)tabView willSelectTabViewItem:(NSTabViewItem *)tabViewItem {
    [self updateViewForLabel:[tabViewItem label]];
}

// Update one of the views in the tab view based on a label name. This happens
// in the delegate method above, but we can also call it manually, for example
// to set the initial view.
- (void)updateViewForLabel:(NSString *)label {
    // TODO: This is just some fragile proof of concept code.
    if ([label isEqualToString:@"Home"]) {
        [[self ipfsController] daemonGetId];
    }
    else if ([label isEqualToString:@"Connections"]) {
        [[self ipfsController] daemonGetSwarm];
    }
}

@end
