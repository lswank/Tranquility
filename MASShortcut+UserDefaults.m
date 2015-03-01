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

#import "MASShortcut+UserDefaults.h"
#import "MASShortcut+Monitoring.h"

#pragma mark MASShortcutUserDefaultsHotKey class interface
@interface MASShortcutUserDefaultsHotKey : NSObject
    {
    NSString* _userDefaultsKey;
    void ( ^_handler )();
    id _monitor;
    }

@property ( nonatomic, readonly )   NSString* userDefaultsKey;
@property ( nonatomic, copy )       void ( ^handler )();
@property ( nonatomic, retain )     id monitor;

- ( id ) initWithUserDefaultsKey: ( NSString* )_UserDefaultsKey
                         handler: ( void (^)() )_Handler;

@end // MASShortcutUserDefaultsHotKey class interface

#pragma mark MASShortcut + MASShortcutUserDefaults
@implementation MASShortcut ( MASShortcutUserDefaults )

+ ( NSMutableDictionary* ) registeredUserDefaultsHotKeys
    {
    NSMutableDictionary static* shared = nil;

    dispatch_once_t static onceToken;
    dispatch_once( &onceToken
        , ^{ shared = [ [ NSMutableDictionary dictionary ] retain ]; } );

    return shared;
    }

+ ( void ) registerGlobalShortcutWithUserDefaultsKey: ( NSString* )_UserDefaultsKey
                                             handler: ( void (^)() )_Handler
    {
    MASShortcutUserDefaultsHotKey* hotKey = [ [ MASShortcutUserDefaultsHotKey alloc ] initWithUserDefaultsKey: _UserDefaultsKey
                                                                                                      handler: _Handler ];
    [ self registeredUserDefaultsHotKeys ][ _UserDefaultsKey ] = hotKey;
    }

+ ( void ) unregisterGlobalShortcutWithUserDefaultsKey: ( NSString* )_UserDefaultsKey
    {
    NSMutableDictionary* registeredHotKeys = [ self registeredUserDefaultsHotKeys ];
    [ registeredHotKeys removeObjectForKey: _UserDefaultsKey ];
    }

@end // MASShortcut + MASShortcutUserDefaults

#pragma mark MASShortcutUserDefaultsHotKey class implementation
@implementation MASShortcutUserDefaultsHotKey

@synthesize monitor = _monitor;
@synthesize handler = _handler;
@synthesize userDefaultsKey = _userDefaultsKey;

#pragma mark Initializers & Deallocator
- ( id ) initWithUserDefaultsKey: ( NSString* )_UserDefaultsKey
                         handler: ( void (^)() )_Handler
    {
    if ( self = [ super init ] )
        {
        _userDefaultsKey = [ _UserDefaultsKey copy ];
        _handler = [ _Handler copy ];

        [ [ NSNotificationCenter defaultCenter] addObserver: self
                                                   selector: @selector( userDefaultsDidChange: )
                                                       name: NSUserDefaultsDidChangeNotification
                                                     object: [ NSUserDefaults standardUserDefaults ] ];
        [ self installHotKeyFromUserDefaults ];
        }

    return self;
    }

- ( void ) dealloc
    {
    [ [ NSNotificationCenter defaultCenter ] removeObserver: self
                                                       name: NSUserDefaultsDidChangeNotification
                                                     object: [ NSUserDefaults standardUserDefaults ] ];

    [ MASShortcut removeGlobalHotkeyMonitor: self.monitor ];
    [ super dealloc ];
    }

#pragma mark -
- ( void ) userDefaultsDidChange: ( NSNotification* )_Notif
    {
    [ MASShortcut removeGlobalHotkeyMonitor: self.monitor ];
    [ self installHotKeyFromUserDefaults ];
    }

- ( void ) installHotKeyFromUserDefaults
    {
    NSData* data = [ [ NSUserDefaults standardUserDefaults ] dataForKey: _userDefaultsKey ];
    MASShortcut* shortcut = [ MASShortcut shortcutWithData: data ];

    if ( !shortcut )
        return;

    self.monitor = [ MASShortcut addGlobalHotkeyMonitorWithShortcut: shortcut
                                                            handler: self.handler ];
    }

@end // MASShortcutUserDefaultsHotKey class implementation

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