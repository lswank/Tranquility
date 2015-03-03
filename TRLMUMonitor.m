//
//  TRLMUMonitor.m
//  Tranquility
//
//  Assumed by Lorenzo Swank on 2014 FEB 05 and
//  updated for Mac OS 10.9.
//
//  Orginally Created by Nicholas Jitkoff on 5/8/07 as Nocturne.
//  Licensed under the Apache 2.0 license and distributed as such
//  on https://code.google.com/p/blacktree-nocturne
//

#import "TRLMUMonitor.h"


@implementation TRLMUMonitor
+ (void)initialize
{
    //[self setKeys:[NSArray arrayWithObject:@"monitorSensors"] triggerChangeNotificationsForDependentKey:@"fuzzyAverage"];
}

- (int)average
{
    return (left + right) / 2;
}

- (int)fuzzyAverage
{
    if (left + right < 0)
    {
        return 0;
    }

    return (left + right) / 2 + ((rand() % 3) - 2);
}

- (int)maxValue
{
    return 1600;
}

- (float)percent
{
    return 100.0 * (float)[self average] / [self maxValue];
}

- (void)checkValues:(NSTimer*)timer
{
    //IOItemCount   scalarInputCount = 0;
    //IOItemCount   scalarOutputCount = 2;
    /*
       SInt32 newLeft;
       SInt32 newRight;
       kern_return_t kr = IOConnectMethodScalarIScalarO(dataPort, kGetSensorReadingID,
       scalarInputCount, scalarOutputCount, &newLeft, &newRight);
       if (kr == KERN_SUCCESS) {

       SInt32 oldAvg = (left + right) / 2 ;
       SInt32 newAvg = (newLeft + newRight) / 2;
       if (newAvg > 0) {
       if (newAvg < lowerBound && oldAvg >= lowerBound) {
       [delegate monitor:self passedLowerBound:lowerBound withValue:newAvg];
       }
       if (newAvg > upperBound && oldAvg <= upperBound){
       [delegate monitor:self passedUpperBound:upperBound withValue:newAvg];
       }
       }
       if (sendNotifications) {
       [self willChangeValueForKey:@"fuzzyAverage"];
       [self willChangeValueForKey:@"percent"];
       [self didChangeValueForKey:@"fuzzyAverage"];
       [self didChangeValueForKey:@"percent"];
       }
       left = newLeft;
       right = newRight;
       //NSLog(@"%8ld %8ld %d", lowerBound, upperBound, newAvg);

       return;
       }

       // NSLog(@"kr %x", kr);

       if (kr == kIOReturnBusy) return;
       mach_error("I/O Kit error:", kr);
       //  exit(kr);
     */
}

+ (BOOL)hasSensors
{
    io_service_t serviceObject = IOServiceGetMatchingService(kIOMasterPortDefault,
                                                             IOServiceMatching("AppleLMUController"));

    if (!serviceObject)
    {
        serviceObject = IOServiceGetMatchingService(kIOMasterPortDefault,
                                                    IOServiceMatching("IOI2CDeviceLMU"));
    }

    if (!serviceObject)
    {
        return NO;
    }

    IOObjectRelease(serviceObject);
    return YES;
}

- (id)init
{
    self = [super init];

    if (self != nil)
    {
        left = -1;
        right = -1;
        sendNotifications = [NSApp isActive];
        // Look up a registered IOService object whose class is AppleLMUController
        io_service_t serviceObject = IOServiceGetMatchingService(kIOMasterPortDefault,
                                                                 IOServiceMatching("AppleLMUController"));

        if (!serviceObject)
        {
            serviceObject = IOServiceGetMatchingService(kIOMasterPortDefault,
                                                        IOServiceMatching("IOI2CDeviceLMU"));
        }

        if (!serviceObject)
        {
            fprintf(stderr, "failed to find ambient light sensor\n");
            [self release];
            return nil;
        }

        // Create a connection to the IOService object
        kern_return_t kr = IOServiceOpen(serviceObject, mach_task_self(), 0, &dataPort);
        IOObjectRelease(serviceObject);

        if (kr != KERN_SUCCESS)
        {
            mach_error("IOServiceOpen:", kr);
            exit(kr);
        }

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appWillActivate:)
                                                     name:NSApplicationWillBecomeActiveNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appDidResign:)
                                                     name:NSApplicationDidResignActiveNotification
                                                   object:nil];
        [self setMonitorSensors:YES];
    }

    return self;
}

- (void)removeTimer
{
    [checkTimer invalidate];
    checkTimer = nil;
}

- (void)scheduleTimerWithInterval:(float)interval
{
    [self removeTimer];
    checkTimer = [[NSTimer scheduledTimerWithTimeInterval:interval
                                                   target:self
                                                 selector:@selector(checkValues:)
                                                 userInfo:nil
                                                  repeats:YES] retain];
}

- (void)appWillActivate:(id)sender
{
    if (checkTimer)
    {
        [self scheduleTimerWithInterval:0.3333];
    }

    sendNotifications = YES;
}

- (void)appDidResign:(id)sender
{
    if (checkTimer)
    {
        [self scheduleTimerWithInterval:1.0];
    }

    sendNotifications = NO;
}

- (void)setMonitorSensors:(BOOL)flag
{
    if (flag)
    {
        if (!checkTimer)
        {
            [self scheduleTimerWithInterval:[NSApp isActive] ? 0.33333:1.0];
            [self checkValues:nil];
        }
    }
    else
    {
        [self removeTimer];
    }

    left = -1;
    right = -1;
}

- (void)dealloc
{
    [checkTimer invalidate];
    checkTimer = nil;
    [self setDelegate:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (id)delegate
{
    return [[delegate retain] autorelease];
}

- (void)setDelegate:(id)value
{
    if (delegate != value)
    {
        [delegate release];
        delegate = [value retain];
    }
}

- (SInt32)lowerBound
{
    return lowerBound;
}

- (void)setLowerBound:(SInt32)value
{
    lowerBound = value;
}

- (SInt32)upperBound
{
    return upperBound;
}

- (void)setUpperBound:(SInt32)value
{
    upperBound = value;
}

@end
