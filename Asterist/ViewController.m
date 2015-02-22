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

- (void)awakeFromNib {
    NSFont *smallSystemFont = [NSFont userFixedPitchFontOfSize:[NSFont smallSystemFontSize]];
    [[self configTextView] setFont:smallSystemFont];
    [[self publicKeyTextView] setFont:smallSystemFont];
}

// This method is called every time a tab is selected in a tab view.
- (void)tabView:(NSTabView *)tabView willSelectTabViewItem:(NSTabViewItem *)tabViewItem {
    if ([tabView isEqual:[self tabView]]) {
        [self updateViewForLabel:[tabViewItem label]];
    }
    else if ([tabView isEqual:[self filesTabView]]) {
        [self updateFileViewForLabel:[tabViewItem label]];
    }
}

// Update one of the views in the main tab view based on label. This happens in
// the delegate method above, but we can also call it manually, for example to
// set the initial view.
- (void)updateViewForLabel:(NSString *)label {
    // TODO: This is just some fragile proof of concept code.

    // Stop any timers if the view using that timer is not the selected one.
    if (![label isEqualToString:@"Connections"]) {
        [[self ipfsController] stopSwarmUpdateTimer];
    }

    if ([label isEqualToString:@"Home"]) {
        [[self ipfsController] daemonGetId];
    }
    else if ([label isEqualToString:@"Connections"]) {
        [[self ipfsController] daemonGetSwarm];
        [[self ipfsController] startSwarmUpdateTimer];
    }
    else if ([label isEqualToString:@"Files"]) {
        NSString *currentlySelectedLabel = [[[self filesTabView] selectedTabViewItem] label];
        [self updateFileViewForLabel:currentlySelectedLabel];
    }
    else if ([label isEqualToString:@"Config"]) {
        [[self ipfsController] daemonGetConfig];
    }
}

// Update one of the views in the files tab view, which is itself a child of the
// "Files" item in the main tab view.
- (void)updateFileViewForLabel:(NSString *)label {
    if ([label isEqualToString:@"Pinned"]) {
        [[self ipfsController] daemonGetPinnedFiles];
    }
    else if ([label isEqualToString:@"All"]) {
        [[self ipfsController] daemonGetLocalFiles];
    }
}

@end
