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

#import "MASShortcut+Monitoring.h"

NSMutableDictionary* MASRegisteredHotKeys();
BOOL InstallCommonEventHandler();
BOOL InstallHotkeyWithShortcut( MASShortcut* _Shortcut, UInt32* _OutCarbonHotKeyID, EventHotKeyRef* _OutCarbonHotKey );
void UninstallEventHandler();

#pragma mark MASShortcutHotKey class interface
@interface MASShortcutHotKey : NSObject
    {
    MASShortcut*    _shortcut;
    void ( ^_handler )();
    EventHotKeyRef  _carbonHotKey;
    UInt32          _carbonHotKeyID;
    }

@property ( nonatomic, readonly, retain ) MASShortcut* shortcut;
@property ( nonatomic, readonly, copy ) void ( ^handler )();
@property ( nonatomic, readonly ) EventHotKeyRef carbonHotKey;
@property ( nonatomic, readonly ) UInt32 carbonHotKeyID;

- ( id ) initWithShortcut: ( MASShortcut* )_Shortcut
                  handler: ( void (^)() )_Handler;

- ( void ) uninstallExistingHotKey;

@end // MASShortcutHotKey class interface

#pragma mark MASShortcut + MASShorcutMonitoring
@implementation MASShortcut ( MASShorcutMonitoring )

+ ( MASShortcutMonitor* ) addGlobalHotkeyMonitorWithShortcut: ( MASShortcut* )_Shortcut
                                                     handler: ( void (^)() )_Handler
    {
    MASShortcutMonitor* monitor = [ NSString stringWithFormat: @"%@", _Shortcut.description ];

    if ( [ MASRegisteredHotKeys() objectForKey: monitor ] )
        return nil;

    MASShortcutHotKey* hotKey = [ [ [ MASShortcutHotKey alloc ] initWithShortcut: _Shortcut
                                                                         handler: _Handler ] autorelease ];
    if ( hotKey == nil )
        return nil;

    MASRegisteredHotKeys()[ monitor ] = hotKey;

    return monitor;
    }

+ ( void ) removeGlobalHotkeyMonitor: ( MASShortcutMonitor* )_Monitor;
    {
    if ( !_Monitor )
        return;

    NSMutableDictionary* registeredHotKeys = MASRegisteredHotKeys();
    MASShortcutHotKey* hotKey = [ registeredHotKeys objectForKey: _Monitor ];

    if ( hotKey )
        [ hotKey uninstallExistingHotKey ];

    [ registeredHotKeys removeObjectForKey: _Monitor ];

    if ( registeredHotKeys.count == 0 )
        UninstallEventHandler();
    }

@end // MASShortcut + MASShorcutMonitoring

#pragma mark MASShortcutHotKey class implementation
@implementation MASShortcutHotKey

@synthesize carbonHotKeyID = _carbonHotKeyID;
@synthesize handler = _handler;
@synthesize shortcut = _shortcut;
@synthesize carbonHotKey = _carbonHotKey;

#pragma mark Initializers & deallocator
- ( id ) initWithShortcut: ( MASShortcut* )_Shortcut
                  handler: ( void (^)() )_Handler;
    {
    if ( self = [ super init ] )
        {
        _shortcut = [ _Shortcut retain ];
        _handler = [ _Handler copy ];

        if ( !InstallHotkeyWithShortcut( _Shortcut, &_carbonHotKeyID, &_carbonHotKey ) )
            {
            // Conquer or to die😈
            [ self release ];
            self = nil;
            }
        }

    return self;
    }

- ( void ) dealloc
    {
    [ _shortcut release ];
    [ self uninstallExistingHotKey ];
    [ super dealloc ];
    }

#pragma mark -
- ( void ) uninstallExistingHotKey
    {
    if ( _carbonHotKey )
        {
        UnregisterEventHotKey( _carbonHotKey );
        _carbonHotKey = NULL;
        }
    }

@end // MASShortcutHotKey class implementation

#pragma mark Carbon magic
NSMutableDictionary* MASRegisteredHotKeys()
    {
    NSMutableDictionary static* shared = nil;
    dispatch_once_t static onceToken;

    dispatch_once( &onceToken,
        ^{ shared = [ [ NSMutableDictionary dictionary ] retain ]; } );

    return shared;
    }

FourCharCode const kMASShortcutSignature = 'MASS';
BOOL InstallHotkeyWithShortcut( MASShortcut* _Shortcut, UInt32* _OutCarbonHotKeyID, EventHotKeyRef* _OutCarbonHotKey )
    {
    if ( ( _Shortcut == nil ) || !InstallCommonEventHandler() )
        return NO;

    static UInt32 sCarbonHotKeyID = 0;
	EventHotKeyID hotKeyID = { .signature = kMASShortcutSignature, .id = ++sCarbonHotKeyID };
    EventHotKeyRef carbonHotKey = NULL;
    if ( RegisterEventHotKey( _Shortcut.carbonKeyCode
                            , _Shortcut.carbonFlags
                            , hotKeyID
                            , GetEventDispatcherTarget()
                            , kEventHotKeyExclusive
                            , &carbonHotKey
                            ) != noErr )
        return NO;

    if ( _OutCarbonHotKeyID )
        *_OutCarbonHotKeyID = hotKeyID.id;

    if ( _OutCarbonHotKey )
        *_OutCarbonHotKey = carbonHotKey;

    return YES;
    }

static OSStatus CarbonCallback( EventHandlerCallRef _InHandlerCallRef, EventRef _InEvent, void* _InUserData )
    {
	if ( GetEventClass( _InEvent ) != kEventClassKeyboard )
        return noErr;

	EventHotKeyID hotKeyID;
	OSStatus status = GetEventParameter( _InEvent
                                       , kEventParamDirectObject
                                       , typeEventHotKeyID
                                       , NULL
                                       , sizeof( hotKeyID )
                                       , NULL
                                       , &hotKeyID
                                       );
	if ( status != noErr )
        return status;

	if ( hotKeyID.signature != kMASShortcutSignature )
        return noErr;

    [ MASRegisteredHotKeys() enumerateKeysAndObjectsUsingBlock:
        ^( id _Key, MASShortcutHotKey* _HotKey, BOOL* _Stop)
            {
            if ( hotKeyID.id == _HotKey.carbonHotKeyID )
                {
                if ( _HotKey.handler )
                    _HotKey.handler();

                *_Stop = YES;
                }
            } ];

	return noErr;
    }

static EventHandlerRef sEventHandler = NULL;
BOOL InstallCommonEventHandler()
    {
    if ( !sEventHandler )
        {
        EventTypeSpec hotKeyPressedSpec = { .eventClass = kEventClassKeyboard, .eventKind = kEventHotKeyPressed };
        OSStatus status = InstallEventHandler( GetEventDispatcherTarget()
                                             , CarbonCallback
                                             , 1
                                             , &hotKeyPressedSpec
                                             , NULL
                                             , &sEventHandler
                                             );
        if ( status != noErr )
            {
            sEventHandler = NULL;
            return NO;
            }
        }

    return YES;
    }

void UninstallEventHandler()
    {
    if ( sEventHandler )
        {
        RemoveEventHandler( sEventHandler );
        sEventHandler = NULL;
        }
    }

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