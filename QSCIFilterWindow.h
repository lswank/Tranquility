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
	void * fid;
}
- (void)setFilter:(NSString *)filter;
- (void)setFilterValues:(NSDictionary *)filterValues;
//- (void)setLevel:(int)level;
//- (void)createOverlay;
@end
