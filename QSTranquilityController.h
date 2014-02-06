/* QSTranquilityController */

#import <Cocoa/Cocoa.h>
#include "CGSPrivate.h"

#import "QSCIFilterWindow.h"
#import "QSLMUMonitor.h"

@interface QSTranquilityController : NSObject
{
    CGGammaValue gOriginalRedTable[ 256 ];
    CGGammaValue gOriginalGreenTable[ 256 ];
    CGGammaValue gOriginalBlueTable[ 256 ];
    NSMutableArray *desktopWindows;
    NSMutableArray *overlayWindows;
    IBOutlet NSWindow *prefsWindow;
    IBOutlet NSMenu *statusMenu;
    IBOutlet NSTextField *versionTextField;
    BOOL shouldQuit;
    
    BOOL enabled;
    
    NSColor *whiteColor;
    NSColor *blackColor;
    NSStatusItem *statusItem;
    float originalBrightness;
    QSLMUMonitor *monitor;
    
    
    NSWindow *menuWindow;
    QSCIFilterWindow *menuHueOverlay;
    QSCIFilterWindow *menuInvertOverlay;
    NSArray *windows;
    BOOL trackingMenu;
    BOOL visible;
    BOOL shouldHide;
    BOOL correctHue;
    BOOL dimMenu;
    BOOL invertMenuAlways;
}

@property(nonatomic, assign) BOOL dimMenu;
@property(nonatomic, assign) BOOL invertMenuAlways;

- (IBAction)toggle:(id)sender;

- (void)setDesktopHidden:(BOOL)hidden;

- (IBAction)showPreferences:(id)sender;
- (BOOL)enabled;
- (void)setEnabled:(BOOL)value;

- (NSColor *)whiteColor;
- (void)setWhiteColor:(NSColor *)value;

- (NSColor *)blackColor;
- (void)setBlackColor:(NSColor *)value;

- (void)updateGamma;

- (float)getDisplayBrightness;
- (IBAction)revertGamma:(id)sender;

- (QSLMUMonitor *)lightMonitor;

- (void)removeOverlays;
- (void)setupOverlays;



@end

@interface QSTranquilityController (MenuCovers)

- (void)setDimMenu:(BOOL)flag;

@end
