//
//  TRLMUMonitor.h
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
#include <mach/mach.h>
#include <IOKit/IOKitLib.h>
#include <CoreFoundation/CoreFoundation.h>


#ifndef LMUCOMMON_H
#define LMUCOMMON_H

enum
{
    kGetSensorReadingID   = 0,  // getSensorReading(int *, int *)
    kGetLEDBrightnessID   = 1,  // getLEDBrightness(int, int *)
    kSetLEDBrightnessID   = 2,  // setLEDBrightness(int, int, int *)
    kSetLEDFadeID         = 3,  // setLEDFade(int, int, int, int *)

    // other firmware-related functions
    // verifyFirmwareID     = 4,  // verifyFirmware(int *)
    // getFirmwareVersionID = 5,  // getFirmwareVersion(int *)

    // other flashing-related functions
    // ...
};

#endif


@interface TRLMUMonitor : NSObject {
    NSTimer* checkTimer;
    io_connect_t dataPort;


    SInt32 left;
    SInt32 right;

    id delegate;
    SInt32 lowerBound;
    SInt32 upperBound;
    BOOL sendNotifications;
}

- (id)delegate;
- (void)setDelegate:(id)value;

- (SInt32)lowerBound;
- (void)setLowerBound:(SInt32)value;

- (SInt32)upperBound;
- (void)setUpperBound:(SInt32)value;

- (void)setMonitorSensors:(BOOL)flag;

+ (BOOL)hasSensors;

@end

@interface NSObject (TRLMUMonitorDelegate)

- (void)monitor:(TRLMUMonitor*)monitor passedLowerBound:(SInt32)lowerBound withValue:(SInt32)value;
- (void)monitor:(TRLMUMonitor*)monitor passedUpperBound:(SInt32)upperBound withValue:(SInt32)value;
@end
