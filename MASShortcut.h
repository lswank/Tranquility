///:
/*****************************************************************************
 **                                                                         **
 **                               .======.                                  **
 **                               | INRI |                                  **
 **                               |      |                                  **
 **                               |      |                                  **
 **                      .========'      '========.                         **
 **                      |   _      xxxx      _   |                         **
 **                      |  /_;-.__ / _\  _.-;_\  |                         **
 **                      |     `-._`'`_/'`.-'     |                         **
 **                      '========.`\   /`========'                         **
 **                               | |  / |                                  **
 **                               |/-.(  |                                  **
 **                               |\_._\ |                                  **
 **                               | \ \`;|                                  **
 **                               |  > |/|                                  **
 **                               | / // |                                  **
 **                               | |//  |                                  **
 **                               | \(\  |                                  **
 **                               |  ``  |                                  **
 **                               |      |                                  **
 **                               |      |                                  **
 **                               |      |                                  **
 **                               |      |                                  **
 **                   \\    _  _\\| \//  |//_   _ \// _                     **
 **                  ^ `^`^ ^`` `^ ^` ``^^`  `^^` `^ `^                     **
 **                                                                         **
 **                Created by Vadim Shpakovski Originally                   **
 **           GitHub: https://github.com/shpakovski/MASShortcut             **
 **                                                                         **
 **                                                                         **
 **                 Forked and Changed by Richard Heard                     **
 **            GitHub: https://github.com/heardrwt/MASShortcut              **
 **                                                                         **
 **                                                                         **
 **             Forked, Changed and Republished by Tong Guo                 **
 **             GitHub: https://github.com/TongG/MASShortcut                **
 **                                                                         **
 **                       Copyright (c) 2014 Tong G.                        **
 **                          ALL RIGHTS RESERVED.                           **
 **                                                                         **
 ****************************************************************************/

#import <Carbon/Carbon.h>
#import <Cocoa/Cocoa.h>

/* Convert the C-style char to NSString object */
#define MASShortcutChar( _Char ) [ NSString stringWithFormat: @"%C", ( unsigned short )( _Char ) ]

/* Leaving only the NSControlKeyMask, NSShiftKeyMask, NSAlternateKeyMask and NSCommandKeyMask
 * filter out all of others */
#define MASShortcutClear( _Flags ) ( _Flags & ( NSControlKeyMask | NSShiftKeyMask | NSAlternateKeyMask | NSCommandKeyMask ) )

/* Map the Cocoa's modifier flags to Carbon's */
#define MASShortcutCarbonFlags( _CocoaFlags ) (                 \
    ( _CocoaFlags & NSCommandKeyMask ? cmdKey : 0 )             \
        | ( _CocoaFlags & NSAlternateKeyMask ? optionKey : 0 )  \
        | ( _CocoaFlags & NSControlKeyMask ? controlKey : 0 )   \
        | ( _CocoaFlags & NSShiftKeyMask ? shiftKey : 0 ) )

/* These glyphs are missed in Carbon.h */
enum { kMASShortcutGlyphEject = 0x23CF
     , kMASShortcutGlyphClear = 0x2715
     , kMASShortcutGlyphDeleteLeft = 0x232B
     , kMASShortcutGlyphDeleteRight = 0x2326
     , kMASShortcutGlyphLeftArrow = 0x2190
	 , kMASShortcutGlyphRightArrow = 0x2192
	 , kMASShortcutGlyphUpArrow = 0x2191
	 , kMASShortcutGlyphDownArrow = 0x2193
	 , kMASShortcutGlyphEscape = 0x238B
	 , kMASShortcutGlyphHelp = 0x003F
     , kMASShortcutGlyphPageDown = 0x21DF
	 , kMASShortcutGlyphPageUp = 0x21DE
	 , kMASShortcutGlyphTabRight = 0x21E5
	 , kMASShortcutGlyphReturn = 0x2305
	 , kMASShortcutGlyphReturnR2L = 0x21A9
	 , kMASShortcutGlyphPadClear = 0x2327
	 , kMASShortcutGlyphNorthwestArrow = 0x2196
	 , kMASShortcutGlyphSoutheastArrow = 0x2198
     } MASShortcutGlyph;

@interface MASShortcut : NSObject <NSCoding>
    {
@private
    NSUInteger _keyCode;        // NSNotFound if empty
    NSUInteger _modifierFlags;  // 0 if empty
    }

@property ( nonatomic ) NSUInteger keyCode;
@property ( nonatomic ) NSUInteger modifierFlags;
@property ( nonatomic, readonly ) UInt32 carbonKeyCode;
@property ( nonatomic, readonly ) UInt32 carbonFlags;
@property ( nonatomic, readonly ) NSString* keyCodeString;
@property ( nonatomic, readonly ) NSString* keyCodeStringForKeyEquivalent;
@property ( nonatomic, readonly ) NSString* modifierFlagsString;
@property ( nonatomic, readonly ) NSData* data;
@property ( nonatomic, readonly ) BOOL shouldBypass;
@property ( nonatomic, readonly, getter = isValid ) BOOL valid;

- ( id ) initWithKeyCode: ( NSUInteger )_Code
           modifierFlags: ( NSUInteger )_Flags;

+ ( MASShortcut* ) shortcutWithKeyCode: ( NSUInteger )_Code
                         modifierFlags: ( NSUInteger )_Flags;

/* The _Event parameter must be a key event, otherwise the assertion will be failure */
+ ( MASShortcut* ) shortcutWithEvent: ( NSEvent* )_Event;

+ ( MASShortcut* ) shortcutWithData: ( NSData* )_Data;

/* Check if any of shortcuts in mainMenu of current application and system-wide set maches current shorcut */
- ( BOOL ) isTakenError: ( NSError** )_Error;

- ( BOOL ) isKeyEquivalent: ( NSString* )_KeyEquivalent
                     flags: ( NSUInteger )_Flags
               takenInMenu: ( NSMenu* )_Menu
                     error: ( NSError** )_OutError;

// The following API enable hotkeys with the ⌥ key as the only modifier
// For example, ⌥G will not generate © and ⌥R will not paste ®
+ ( void ) setAllowsAnyHotkeyWithOptionModifier: ( BOOL )_Allow;
+ ( BOOL ) allowsAnyHotkeyWithOptionModifier;

@end

#pragma mark Error Recovery Attempting
@interface MASShortcut ( MASShortcutErrorRecoveryAttempting )

- ( void ) attemptRecoveryFromError: ( NSError* )_Error
                        optionIndex: ( NSUInteger )_RecoveryOptionIndex
                           delegate: ( id )_Delegate
                 didRecoverSelector: ( SEL )_DidRecoverySelector
                        contextInfo: ( void* )_ContextInfo;

@end // MASShortcut + MASShortcutErrorRecoveryAttempting

//import the other headers so we can include the framework in the usual fashion.
#import "MASShortcut+Monitoring.h"
#import "MASShortcut+UserDefaults.h"
#import "MASShortcutView.h"
#import "MASShortcutView+UserDefaults.h"

//////////////////////////////////////////////////////////////////////////////

/*****************************************************************************
 **                                                                         **
 **      _________                                      _______             **
 **     |___   ___|                                   / ______ \            **
 **         | |     _______   _______   _______      | /      |_|           **
 **         | |    ||     || ||     || ||     ||     | |    _ __            **
 **         | |    ||     || ||     || ||     ||     | |   |__  \           **
 **         | |    ||     || ||     || ||     ||     | \_ _ __| |  _        **
 **         |_|    ||_____|| ||     || ||_____||      \________/  |_|       **
 **                                           ||                            **
 **                                    ||_____||                            **
 **                                                                         **
 ****************************************************************************/
///: