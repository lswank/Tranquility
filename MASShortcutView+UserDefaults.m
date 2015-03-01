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

#import "MASShortcutView+UserDefaults.h"
#import "MASShortcut.h"
#import <objc/runtime.h>

NSString static* kKeyPathForShortcutValueInShortcutViewObject = @"shortcutValue";

#pragma mark MASShortcutDefaultsObserver interface
@interface MASShortcutDefaultsObserver : NSObject
    {
    MASShortcut*        _originalShortcut;
    BOOL                _internalPreferenceChange;
    BOOL                _internalShortcutChange;
    NSString*           _userDefaultsKey;
    MASShortcutView*    _shortcutView;
    }

@property ( nonatomic, readonly ) NSString* userDefaultsKey;
@property ( nonatomic, readonly, unsafe_unretained ) MASShortcutView* shortcutView;

- ( id ) initWithShortcutView: ( MASShortcutView* )_ShortcutView
              userDefaultsKey: ( NSString* )_UserDefaultsKey;
@end

#pragma mark MASShortcutView + MASShortcutViewUserDefaults
@implementation MASShortcutView ( MASShortcutViewUserDefaults )

void* kDefaultsObserver = &kDefaultsObserver;

- ( NSString* ) associatedUserDefaultsKey
    {
    MASShortcutDefaultsObserver* defaultsObserver = objc_getAssociatedObject( self, kDefaultsObserver );
    return defaultsObserver.userDefaultsKey;
    }

- ( void ) setAssociatedUserDefaultsKey: ( NSString* )_AssociatedUserDefaultsKey
    {
    /* First, stop observing previous shortcut view
     * passed nil to clear the association */
    objc_setAssociatedObject( self, kDefaultsObserver, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC );

    /* Next, start observing current shortcut view */
    MASShortcutDefaultsObserver* defaultsObserver =
        [ [ MASShortcutDefaultsObserver alloc ] initWithShortcutView: self
                                                     userDefaultsKey: _AssociatedUserDefaultsKey ];
    /* Tie the new defaults observer to self... */
    objc_setAssociatedObject( self, kDefaultsObserver, defaultsObserver, OBJC_ASSOCIATION_RETAIN_NONATOMIC );

    /* ...we have specified a strong reference to the associated object (OBJC_ASSOCIATION_RETAIN_NONATOMIC)
     * so we should release it once */
    [ defaultsObserver release ];
    }

@end

#pragma mark MASShortcutDefaultsObserver implementation
@implementation MASShortcutDefaultsObserver

@synthesize userDefaultsKey = _userDefaultsKey;
@synthesize shortcutView = _shortcutView;

#pragma mark Initializers & Deallocator
- ( id ) initWithShortcutView: ( MASShortcutView* )_ShortcutView
              userDefaultsKey: ( NSString* )_UserDefaultsKey
    {
    if ( self = [ super init ] )
        {
        _originalShortcut = _ShortcutView.shortcutValue;
        _shortcutView = _ShortcutView;
        _userDefaultsKey = _UserDefaultsKey.copy;
        [ self startObservingShortcutView ];
        }

    return self;
    }

- ( void ) dealloc
    {
    // __unsafe_unretained _shortcutView is not yet deallocated because it refers MASShortcutDefaultsObserver
    [ self stopObservingShortcutView ];
    [ super dealloc ];
    }

#pragma mark -
void* kShortcutValueObserver = &kShortcutValueObserver;

- ( void ) startObservingShortcutView
    {
    // Read initial shortcut value from user preferences
    NSUserDefaults* defaults = [ NSUserDefaults standardUserDefaults ];
    NSData* data = [ defaults dataForKey: _userDefaultsKey ];
    _shortcutView.shortcutValue = [ MASShortcut shortcutWithData: data ];

    // Observe user preferences to update shortcut value when it changed
    [ [ NSNotificationCenter defaultCenter ] addObserver: self
                                                selector: @selector( userDefaultsDidChange: )
                                                    name: NSUserDefaultsDidChangeNotification
                                                  object: defaults ];

    // Observe the keyboard shortcut that user inputs by hand
    [_shortcutView addObserver: self
                    forKeyPath: kKeyPathForShortcutValueInShortcutViewObject
                       options: 0
                       context: kShortcutValueObserver ];
    }

- ( void ) userDefaultsDidChange: ( NSNotification* )_Note
    {
    // Ignore notifications posted from -[self observeValueForKeyPath:]
    if ( _internalPreferenceChange )
        return;

    _internalShortcutChange = YES;
        NSData* data = [ _Note.object dataForKey: _userDefaultsKey ];
        _shortcutView.shortcutValue = [ MASShortcut shortcutWithData: data ];
    _internalShortcutChange = NO;
    }

- ( void ) stopObservingShortcutView
    {
    // Stop observing keyboard hotkeys entered by user in the shortcut view
    [ _shortcutView removeObserver: self
                        forKeyPath: kKeyPathForShortcutValueInShortcutViewObject
                           context: kShortcutValueObserver ];

    // Stop observing user preferences
    [ [ NSNotificationCenter defaultCenter ] removeObserver: self
                                                       name: NSUserDefaultsDidChangeNotification
                                                     object: [ NSUserDefaults standardUserDefaults ] ];
    // Restore original hotkey in the shortcut view
    _shortcutView.shortcutValue = _originalShortcut;
    }

- ( void ) observeValueForKeyPath: ( NSString* )_KeyPath
                         ofObject: ( id )_Object
                           change: ( NSDictionary* )_Change
                          context: ( void* )_Context
    {
    if ( _Context == kShortcutValueObserver )
        {
        if ( _internalShortcutChange )
            return;

        MASShortcut* shortcut = [ _Object valueForKey: _KeyPath ];

        _internalPreferenceChange = YES;
            NSUserDefaults *defaults = [ NSUserDefaults standardUserDefaults ];
            [ defaults setObject: ( shortcut.data ?  : [ NSKeyedArchiver archivedDataWithRootObject: nil ] )
                          forKey: _userDefaultsKey ];

            [ defaults synchronize ];
        _internalPreferenceChange = NO;
        }
    else
        [ super observeValueForKeyPath: _KeyPath
                              ofObject: _Object
                                change: _Change
                               context: _Context ];
    }

@end

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