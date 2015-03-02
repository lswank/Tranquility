//
//  QSCIEffectOverlay.h
//  Quicksilver
//
//  Created by Nicholas Jitkoff on 11/20/05.
//  Copyright 2005 Blacktree. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CGSPrivate.h"

@interface QSCIFilterWindow : NSWindow {
    CGSWindow wid;
    void *fid;
}
- (void)setFilter:(NSString *)filter;
- (void)setFilterValues:(NSDictionary *)filterValues;
//- (void)setLevel:(int)level;
//- (void)createOverlay;

// Some magical calls
extern void CGSRemoveWindowFilter(CGSConnection cid, CGSWindow wid, void *fid);
extern void CGSReleaseCIFilter(CGSConnection cid, void *fid);
extern OSStatus CGSNewCIFilterByName(CGSConnection cid, CFStringRef filterName, void *fid);
extern OSStatus CGSAddWindowFilter(CGSConnection cid, CGSWindow wid, void *fid, int value);
extern void CGSSetCIFilterValuesFromDictionary(CGSConnection cid, void *fid, CFDictionaryRef filterValues);
@end
