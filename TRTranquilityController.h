//  TRTranquilityController.h
//  Tranquility
//
//  Assumed by Lorenzo Swank on 2014 FEB 05 and
//  updated for Mac OS 10.9.
//
//  Orginally Created by Nicholas Jitkoff on 5/8/07 as Nocturne.
//  Licensed under the Apache 2.0 license and distributed as such
//  on https://code.google.com/p/blacktree-nocturne
//

#import <Cocoa/Cocoa.h>
#include "CGSPrivate.h"

#import "TRCIFilterWindow.h"
#import "TRLMUMonitor.h"

#import <MASShortcut.h>

@interface TRTranquilityController : NSObject
{
    CGGammaValue gOriginalRedTable[ 256 ];
    CGGammaValue gOriginalGreenTable[ 256 ];
    CGGammaValue gOriginalBlueTable[ 256 ];
    NSMutableArray* desktopWindows;
    NSMutableArray* overlayWindows;
    IBOutlet NSWindow* prefsWindow;
    IBOutlet NSMenu* statusMenu;
    IBOutlet NSTextField* versionTextField;
    BOOL shouldQuit;

    BOOL enabled;

    NSColor* whiteColor;
    NSColor* blackColor;
    NSStatusItem* statusItem;
    float originalBrightness;
    TRLMUMonitor* monitor;


    NSWindow* menuWindow;
    TRCIFilterWindow* menuHueOverlay;
    TRCIFilterWindow* menuInvertOverlay;
    NSArray* windows;
    BOOL trackingMenu;
    BOOL visible;
    BOOL shouldHide;
    BOOL correctHue;
    BOOL dimMenu;
    BOOL invertMenuAlways;
}

@property (nonatomic, assign) IBOutlet MASShortcutView* shortcutView;   // should be weak, oh well.

@property (nonatomic, assign) BOOL dimMenu;
@property (nonatomic, assign) BOOL invertMenuAlways;

- (IBAction)toggle:(id)sender;

- (void)setDesktopHidden:(BOOL)hidden;

- (IBAction)showPreferences:(id)sender;
- (BOOL)enabled;
- (void)setEnabled:(BOOL)value;

- (NSColor*)whiteColor;
- (void)setWhiteColor:(NSColor*)value;

- (NSColor*)blackColor;
- (void)setBlackColor:(NSColor*)value;

- (void)updateGamma;

- (float)getDisplayBrightness;
- (IBAction)revertGamma:(id)sender;

- (TRLMUMonitor*)lightMonitor;

- (void)removeOverlays;
- (void)setupOverlays;



@end

@interface TRTranquilityController (MenuCovers)

- (void)setDimMenu:(BOOL)flag;

@end
