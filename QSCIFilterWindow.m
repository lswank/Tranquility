//
//  QSCIEffectOverlay.m
//  Quicksilver
//
//  Created by Nicholas Jitkoff on 11/20/05.
//  Copyright 2005 Blacktree. All rights reserved.
//

#import "QSCIFilterWindow.h"
CGSConnection cid;

void DXSetWindowTag(int wid, CGSWindowTag tag,int state){	
  CGSConnection cid;
  
  cid = _CGSDefaultConnection();
  CGSWindowTag tags[2];
  tags[0] = tags[1] = 0;
  OSStatus retVal = CGSGetWindowTags(cid, wid, tags, 32);
  if(!retVal) {
    tags[0] = tag;
    if (state)
      retVal = CGSSetWindowTags(cid, wid, tags, 32);
    else
      retVal = CGSClearWindowTags(cid, wid, tags, 32);
  }
}

void DXSetWindowIgnoresMouse(int wid, int state){	
  DXSetWindowTag(wid,CGSTagTransparent,state);
}

#define NSRectToCGRect(r) CGRectMake(r.origin.x, r.origin.y, r.size.width, r.size.height)
CGRect QSCGRectFromScreenFrame(NSRect rect){
  CGRect screenBounds = CGDisplayBounds(kCGDirectMainDisplay);
  CGRect cgrect=NSRectToCGRect(rect);
  cgrect.origin.y+=screenBounds.size.height;
  cgrect.origin.y -=rect.size.height;
  
  return cgrect;
}

CGSConnection cid;

@implementation QSCIFilterWindow
+ (void)initialize {
  cid=_CGSDefaultConnection();
}

- (id) init {
  self = [self initWithContentRect:[[NSScreen mainScreen] frame]
                         styleMask:NSBorderlessWindowMask
                           backing:NSBackingStoreBuffered
                             defer:NO];
  if (self != nil) {
    [self setHidesOnDeactivate:NO];
    [self setCanHide:NO];
    [self setIgnoresMouseEvents:YES];
    [self setLevel:CGWindowLevelForKey(kCGCursorWindowLevelKey)];
    [self setOpaque: NO];
    [self setBackgroundColor:[NSColor colorWithDeviceWhite:0.0 alpha:0.0]];
    wid = [self windowNumber];
  }
  return self;
}

- (void) dealloc {
  [self setFilter:nil];
  [super dealloc];
}

- (void)setFilter:(NSString *)filterName{
  if (fid){
    CGSRemoveWindowFilter(cid,wid,fid);
    CGSReleaseCIFilter(cid,fid);
  }
  if (filterName){
    CGError error = CGSNewCIFilterByName(cid, (CFStringRef) filterName, &fid);
    if ( noErr == error ) {
      error = CGSAddWindowFilter(cid,wid,fid, 0x00003001);
      if (error) NSLog(@"addfilter err %d",error);
    }
    if (error) NSLog(@"setfilter err %d",error);
  }
}

-(void)setFilterValues:(NSDictionary *)filterValues{
  if (!fid) return;
  CGSSetCIFilterValuesFromDictionary(cid, fid, (CFDictionaryRef)filterValues);
}
@end
