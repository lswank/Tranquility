//
//  TRCIEffectOverlay.h
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
#import "CGSPrivate.h"

@interface TRCIFilterWindow : NSWindow {
    CGSWindow wid;
    void* fid;
}
- (void)setFilter:(NSString*)filter;
- (void)setFilterValues:(NSDictionary*)filterValues;
//- (void)setLevel:(int)level;
//- (void)createOverlay;

// Some magical calls
extern void CGSRemoveWindowFilter(CGSConnection cid, CGSWindow wid, void* fid);
extern void CGSReleaseCIFilter(CGSConnection cid, void* fid);
extern OSStatus CGSNewCIFilterByName(CGSConnection cid, CFStringRef filterName, void* fid);
extern OSStatus CGSAddWindowFilter(CGSConnection cid, CGSWindow wid, void* fid, int value);
extern void CGSSetCIFilterValuesFromDictionary(CGSConnection cid, void* fid, CFDictionaryRef filterValues);
@end
