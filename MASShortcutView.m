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

#import "MASShortcutView.h"
#import "MASShortcut.h"

#define HINT_BUTTON_WIDTH       23.0f
#define BUTTON_FONT_SIZE        11.0f
#define SEGMENT_CHROME_WIDTH    6.0f

#pragma mark MASShortcutView + ()
@interface MASShortcutView () // Private accessors

@property ( nonatomic, getter = isHinting ) BOOL hinting;
@property ( nonatomic, copy ) NSString* shortcutPlaceholder;

@end // MASShortcutView + ()

#pragma mark MASShortcutView
@implementation MASShortcutView

@synthesize enabled = _enabled;
@synthesize hinting = _hinting;
@synthesize shortcutValue = _shortcutValue;
@synthesize shortcutPlaceholder = _shortcutPlaceholder;
@synthesize shortcutValueChange = _shortcutValueChange;
@synthesize recording = _recording;
@synthesize appearance=_appearance;

#pragma mark Initializers & Deallocator
- ( id ) initWithFrame: ( NSRect )_FrameRect
    {
    if (self = [super initWithFrame:_FrameRect] )
        {
        _shortcutCell = [ [ NSButtonCell alloc ] init ];
        _shortcutCell.buttonType = NSPushOnPushOffButton;
        _shortcutCell.font = [ [ NSFontManager sharedFontManager ] convertFont: [ _shortcutCell font ]
                                                                        toSize: BUTTON_FONT_SIZE ];
        _enabled = YES;

        [ self resetShortcutCellStyle ];
        }

    return self;
    }

- ( void ) dealloc
    {
    [ _shortcutCell release ];
     _shortcutCell = nil;

    [ self activateEventMonitoring: NO ];
    [ self activateResignObserver: NO ];

    [ super dealloc ];
    }

#pragma mark Public accessors
- ( void ) setEnabled: ( BOOL )_YesOrNo
    {
    if (_enabled != _YesOrNo)
        {
        _enabled = _YesOrNo;
        [ self updateTrackingAreas ];

        self.recording = NO;
        [ self setNeedsDisplay: YES ];
        }
    }

- ( void ) setAppearance: ( MASShortcutViewAppearance )_Appearance
    {
    if ( _appearance != _Appearance )
        {
        _appearance = _Appearance;

        [ self resetShortcutCellStyle ];
        [ self setNeedsDisplay: YES ];
        }
    }

- ( void ) resetShortcutCellStyle
    {
    switch (_appearance)
        {
        case MASShortcutViewAppearanceDefault:
            {
            _shortcutCell.bezelStyle = NSRoundRectBezelStyle;
            } break;

        case MASShortcutViewAppearanceTexturedRect:
            {
            _shortcutCell.bezelStyle = NSTexturedRoundedBezelStyle;
            } break;

        case MASShortcutViewAppearanceRounded:
            {
            _shortcutCell.bezelStyle = NSRoundedBezelStyle;
            } break;

        case MASShortcutViewApperanceRecessed:
            {
            _shortcutCell.bezelStyle = NSRecessedBezelStyle;
            } break;
        }
    }

- ( void ) setRecording: ( BOOL )_YesOrNo
    {
    // Only one recorder can be active at the moment
    MASShortcutView static* currentRecorder = nil;

    if ( _YesOrNo && ( currentRecorder != self ) )
        {
        currentRecorder.recording = NO;
        currentRecorder = _YesOrNo ? self : nil;
        }
    
    // Only enabled view supports recording
    if ( _YesOrNo && !self.enabled )
        return;
    
    if ( _recording != _YesOrNo )
        {
        _recording = _YesOrNo;
        self.shortcutPlaceholder = nil;

        [ self resetToolTips ];
        [ self activateEventMonitoring: _recording ];
        [ self activateResignObserver: _recording ];
        [ self setNeedsDisplay: YES ];
        }
    }

- ( void ) setShortcutValue: ( MASShortcut* )_ShortcutValue
    {
    if ( _ShortcutValue != _shortcutValue )
        {
        [ _shortcutValue release ];
        _shortcutValue = [ _ShortcutValue retain ];
        }

    [ self resetToolTips ];
    [ self setNeedsDisplay: YES ];

    if ( self.shortcutValueChange )
        self.shortcutValueChange( self );
    }

- ( void ) setShortcutPlaceholder: ( NSString* )_ShortcutPlaceholder
    {
    if ( _shortcutPlaceholder != _ShortcutPlaceholder )
        {
        [ _shortcutPlaceholder release ];
        _shortcutPlaceholder = _ShortcutPlaceholder.copy;
        }

    [ self setNeedsDisplay: YES ];
    }

#pragma mark Drawing
- ( BOOL ) isFlipped
    {
    return YES;
    }

- ( void ) drawInRect: ( NSRect )_Frame
            withTitle: ( NSString* )_Title
            alignment: ( NSTextAlignment )_Alignment
                state: ( NSCellStateValue )_State
    {
    [ _shortcutCell setTitle: _Title ];
    [ _shortcutCell setAlignment: _Alignment ];
    [ _shortcutCell setState: _State ];
    [ _shortcutCell setEnabled: self.enabled ];

    switch ( _appearance )
        {
        case MASShortcutViewAppearanceDefault:
            {
            [ _shortcutCell drawWithFrame: _Frame
                                   inView: self ];
            } break;

        case MASShortcutViewAppearanceTexturedRect:
        case MASShortcutViewAppearanceRounded:
        case MASShortcutViewApperanceRecessed:
            {
            [_shortcutCell drawWithFrame: NSOffsetRect( _Frame, 0.0, 1.0 )
                                  inView: self ];
            } break;
        }
    }

- ( void ) drawRect: ( NSRect )_DirtyRect
    {
    if ( self.shortcutValue /* User has already recorded at least one shortcut... */ )
        {
        [ self drawInRect: self.bounds
                withTitle: MASShortcutChar( self.recording ? kMASShortcutGlyphEscape : kMASShortcutGlyphDeleteLeft )
                alignment: NSRightTextAlignment
                    state: NSOffState ];
        
        CGRect shortcutRect;
        [ self getShortcutRect: &shortcutRect hintRect: NULL ];

        NSString* hintText = _hinting ? NSLocalizedString( @"Use Old Shortuct", @"Cancel action button for non-empty shortcut in recording state" )
                                      : ( self.shortcutPlaceholder.length > 0 ? self.shortcutPlaceholder
                                                                              : NSLocalizedString( @"Type New Shortcut", @"Non-empty shortcut button in recording state" ) );
        NSString* title = ( self.recording ? hintText
                                           : ( _shortcutValue ? _shortcutValue.description : @"" ) );

        [ self drawInRect: NSRectFromCGRect( shortcutRect )
                withTitle: title
                alignment: NSCenterTextAlignment
                    state: self.isRecording ? NSOnState : NSOffState ];
        }
    else
        {
        if ( self.recording /* The user is going to record a shortcut, but he has not already recorded any shortcut... */ )
            {
            /* Draw the "⎋" from the rightmost of shortcut view
             * the appearance is "push on" */
            [ self drawInRect: self.bounds
                    withTitle: MASShortcutChar( kMASShortcutGlyphEscape )
                    alignment: NSRightTextAlignment
                        state: NSOffState ];

            CGRect shortcutRect;
            [ self getShortcutRect: &shortcutRect hintRect: NULL ];

            NSString* title = ( _hinting ? NSLocalizedString( @"Cancel", @"Cancel action button in recording state" )
                                         : ( self.shortcutPlaceholder.length > 0 ? self.shortcutPlaceholder
                                                                                 : NSLocalizedString( @"Type Shortcut", @"Empty shortcut button in recording state" ) ) );
            /* Draw "Type Shortcut" of shortcut placeholder from the leftmost of shortcut view
             * the appearance is "push off" */
            [ self drawInRect: NSRectFromCGRect( shortcutRect )
                    withTitle: title
                    alignment: NSCenterTextAlignment
                        state: NSOnState ];
            }
        else
            {
            [ self drawInRect: self.bounds
                    withTitle: NSLocalizedString( @"Record Shortcut", @"Empty shortcut button in normal state" )
                    alignment: NSCenterTextAlignment
                        state: NSOffState ];
            }
        }
    }

#pragma mark Mouse handling
/* Divide self.bounds into two component rect:
 * 1. shortcut rect
 * 2. hint rect */
- ( void ) getShortcutRect: ( CGRect* )_ShortcutRectRef
                  hintRect: ( CGRect* )_HintRectRef
    {
    CGRect  shortcutRect;
    CGRect  hintRect;
    CGFloat hintButtonWidth = HINT_BUTTON_WIDTH;

    switch ( self.appearance )
        {
    case MASShortcutViewAppearanceTexturedRect: hintButtonWidth += 2.0; break;
    case MASShortcutViewAppearanceRounded:      hintButtonWidth += 3.0; break;

    default: break;
        }

    CGRectDivide( NSRectToCGRect( self.bounds )
                , &hintRect
                , &shortcutRect
                , hintButtonWidth
                , CGRectMaxXEdge
                );

    if ( _ShortcutRectRef )
        *_ShortcutRectRef = shortcutRect;

    if ( _HintRectRef )
        *_HintRectRef = hintRect;
    }

- ( BOOL ) locationInShortcutRect: ( CGPoint )_Location
    {
    CGRect shortcutRect;
    [ self getShortcutRect: &shortcutRect hintRect: NULL ];

    return CGRectContainsPoint( shortcutRect, NSPointToCGPoint( [ self convertPoint: NSPointFromCGPoint( _Location ) fromView: nil ] ) );
    }

- ( BOOL ) locationInHintRect: ( CGPoint )_Location
    {
    CGRect hintRect;
    [ self getShortcutRect: NULL hintRect: &hintRect ];

    return CGRectContainsPoint( hintRect, NSPointToCGPoint( [ self convertPoint: NSPointFromCGPoint( _Location ) fromView: nil ] ) );
    }

- ( void ) mouseDown: ( NSEvent* )_Event
    {
    if ( self.enabled )
        {
        if ( self.shortcutValue /* The user has already recorded at least one shortcut... */ )
            {
            if ( self.recording )
                {
                if ( [ self locationInHintRect: NSPointToCGPoint( _Event.locationInWindow ) ] )
                    self.recording = NO;
                }
            else
                {
                if ( [ self locationInShortcutRect: NSPointToCGPoint( _Event.locationInWindow ) ] )
                    self.recording = YES;
                else
                    self.shortcutValue = nil;
                }
            }
        else
            { /* The user has not already recorded any shortcut... */
            if ( self.recording /* Has beginning to record... */ )
                {
                if ( [ self locationInHintRect: NSPointToCGPoint( _Event.locationInWindow ) ] )
                    self.recording = NO;
                }
            else /* Has not beginning to record... */
                self.recording = YES;
            }
        }
    else
        [ super mouseDown: _Event ];
    }

#pragma mark Handling mouse over
- ( void ) updateTrackingAreas
    {
    [ super updateTrackingAreas ];
    
    if ( _hintArea )
        {
        [ self removeTrackingArea: _hintArea ];
        [ _hintArea release ];
        _hintArea = nil;
        }
    
    // Forbid hinting if view is disabled
    if ( !self.enabled )
        return;
    
    CGRect hintRect;
    [ self getShortcutRect: NULL hintRect: &hintRect ];

    NSTrackingAreaOptions options = ( NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways | NSTrackingAssumeInside );
    _hintArea = [ [ NSTrackingArea alloc ] initWithRect: NSRectFromCGRect( hintRect )
                                                options: options
                                                  owner: self
                                               userInfo: nil ];
    [ self addTrackingArea: _hintArea ];
    }

- ( void ) setHinting: ( BOOL )_Flag
    {
    if ( _hinting != _Flag )
        {
        _hinting = _Flag;
        [ self setNeedsDisplay: YES ];
        }
    }

- ( void ) mouseEntered: ( NSEvent* )_Event
    {
    self.hinting = YES;
    }

- ( void ) mouseExited: ( NSEvent* )_Event
    {
    self.hinting = NO;
    }

void* kUserDataShortcut = &kUserDataShortcut;
void* kUserDataHint = &kUserDataHint;

- ( void ) resetToolTips
    {
    if ( _shortcutToolTipTag )
        [ self removeToolTip: _shortcutToolTipTag ], _shortcutToolTipTag = 0;

    if ( _hintToolTipTag )
        [self removeToolTip:_hintToolTipTag], _hintToolTipTag = 0;
    
    if ( ( self.shortcutValue == nil ) || self.recording || !self.enabled )
        return;

    CGRect shortcutRect;
    CGRect hintRect;
    [ self getShortcutRect: &shortcutRect hintRect: &hintRect ];

    _shortcutToolTipTag = [ self addToolTipRect: NSRectFromCGRect( shortcutRect )
                                          owner: self
                                       userData: kUserDataShortcut ];

    _hintToolTipTag = [ self addToolTipRect: NSRectFromCGRect( hintRect )
                                      owner: self
                                   userData: kUserDataHint ];
    }

- ( NSString* ) view: ( NSView* )_View
    stringForToolTip: ( NSToolTipTag )_Tag
               point: ( NSPoint )_Point
            userData: ( void* )_Data
    {
    if ( _Data == kUserDataShortcut )
        return NSLocalizedString( @"Click to record new shortcut", @"Tooltip for non-empty shortcut button" );

    else if ( _Data == kUserDataHint )
        return NSLocalizedString( @"Delete shortcut", @"Tooltip for hint button near the non-empty shortcut" );

    return nil;
    }

#pragma mark Event monitoring
- ( void ) activateEventMonitoring: ( BOOL )_ShouldActivate
    {
    BOOL static isActive = NO;

    if ( isActive == _ShouldActivate )
        return;

    isActive = _ShouldActivate;
    
    id static eventMonitor = nil;
    if ( _ShouldActivate )
        {
        __block MASShortcutView* weakSelf = self;
        NSEventMask eventMask = ( NSKeyDownMask | NSFlagsChangedMask );

        eventMonitor = [ NSEvent addLocalMonitorForEventsMatchingMask: eventMask
                                                              handler:
            ^( NSEvent* _Event )
                {
                MASShortcut* shortcut = [ MASShortcut shortcutWithEvent: _Event ];

                if ( ( shortcut.keyCode == kVK_Delete ) || ( shortcut.keyCode == kVK_ForwardDelete ) )
                    {
                    // Delete shortcut
                    weakSelf.shortcutValue = nil;
                    weakSelf.recording = NO;
                    _Event = nil;
                    }
                else if ( shortcut.keyCode == kVK_Escape )
                    {
                    // Cancel recording
                    weakSelf.recording = NO;
                    _Event = nil;
                    }
                else if ( shortcut.shouldBypass )
                    {
                    // Command + W, Command + Q, ESC should deactivate recorder
                    weakSelf.recording = NO;
                    }
                else
                    {
                    // Verify possible shortcut
                    if ( shortcut.keyCodeString.length > 0 )
                        {
                        if ( shortcut.valid )
                            {
                            // Verify that shortcut is not used
                            NSError* error = nil;

                            if ( [ shortcut isTakenError: &error ] )
                                {
                                // Prevent cancel of recording when Alert window is key
                                [ weakSelf activateResignObserver: NO ];
                                [ weakSelf activateEventMonitoring: NO ];

                                [ self presentError: error
                                     modalForWindow: [ self window ]
                                           delegate: self
                                 didPresentSelector: @selector( didPresentErrorWithRecovery:contextInfo: )
                                        contextInfo: NULL ];

                                weakSelf.shortcutPlaceholder = nil;
                                [ weakSelf activateResignObserver: YES ];
                                [ weakSelf activateEventMonitoring: YES ];
                                }
                            else
                                {
                                weakSelf.shortcutValue = shortcut;
                                weakSelf.recording = NO;
                                }
                            }
                        else
                            // Key press with or without SHIFT is not valid input
                            NSBeep();
                        }
                    else
                        // User is playing with modifier keys
                        weakSelf.shortcutPlaceholder = shortcut.modifierFlagsString;

                    _Event = nil;
                    }

            return _Event;
            } ];
        }
    else
        [ NSEvent removeMonitor: eventMonitor ];
    }

- ( void ) activateResignObserver: ( BOOL )_ShouldActivate
    {
    BOOL static isActive = NO;

    if ( isActive == _ShouldActivate )
        return;

    isActive = _ShouldActivate;
    
    id static observer = nil;
    NSNotificationCenter* notificationCenter = [ NSNotificationCenter defaultCenter];

    if ( _ShouldActivate )
        {
        __block MASShortcutView* weakSelf = self;
        observer = [ notificationCenter addObserverForName: NSWindowDidResignKeyNotification
                                                    object: self.window
                                                     queue: [ NSOperationQueue mainQueue ]
                                                usingBlock:
            ^( NSNotification* notification )
                {
                weakSelf.recording = NO;
                } ];
        }
    else
        [ notificationCenter removeObserver: observer ];
    }

- ( void ) didPresentErrorWithRecovery: ( BOOL )_DidRecovery
                           contextInfo: ( void* )_ContextInfo
    {
    if ( !_DidRecovery && _ContextInfo && [ ( id )_ContextInfo isKindOfClass: [ NSError class ] ] )
        [ self presentError: ( NSError* )_ContextInfo ];
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