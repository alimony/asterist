//
//  ViewController.h
//  Asterist
//
//  Created by Markus Amalthea Magnuson on 2014-12-27.
//  Copyright (c) 2014 Markus Amalthea Magnuson. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class WebView;

@interface ViewController : NSViewController

@property (weak) IBOutlet WebView *webView;
@property (weak) IBOutlet NSProgressIndicator *spinner;
@property (weak) IBOutlet NSTextField *spinnerText;

@end
