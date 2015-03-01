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

#import <Cocoa/Cocoa.h>

@class MASShortcut;

typedef enum
    { MASShortcutViewAppearanceDefault = 0      // Height = 19 px
    , MASShortcutViewAppearanceTexturedRect     // Height = 25 px
    , MASShortcutViewAppearanceRounded          // Same as TexturedRect
    , MASShortcutViewApperanceRecessed          // Same as TexturedRect
    } MASShortcutViewAppearance;

#pragma mark MASShortcutView class
@interface MASShortcutView : NSView
    {
@private
    NSButtonCell*   _shortcutCell;
    NSInteger       _shortcutToolTipTag;
    NSInteger       _hintToolTipTag;
    NSTrackingArea* _hintArea;
    
    BOOL            _enabled;

    /* YES when the mouse pointer enter the hint field
     * and be NO when the mouse pointer exit there */
    BOOL            _hinting;

    MASShortcut*    _shortcutValue;

    /* Just a placeholder that display in the highlighted shortcut view
     * for example: while the key combination is "⌃⌘W",
     * the shortcut placeholder is "⌃⌘" */
    NSString*       _shortcutPlaceholder;

    BOOL            _recording;

    MASShortcutViewAppearance _appearance;

    void ( ^_shortcutValueChange )( MASShortcutView* _Sender );
    }

@property ( nonatomic, strong ) MASShortcut *shortcutValue;
@property ( nonatomic, getter = isRecording ) BOOL recording;
@property ( nonatomic, getter = isEnabled ) BOOL enabled;
@property ( nonatomic ) MASShortcutViewAppearance appearance;

@property ( nonatomic, copy ) void ( ^shortcutValueChange )( MASShortcutView* sender );

@end // MASShortcutView class

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