//
//  Supervisor.m
//  Supervisor-NSTask
//
//  Created by ENDOH takanao on 11/13/13.
//  Copyright (c) 2013 ENDOH takanao. All rights reserved.
//

#import "Supervisor.h"

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define DLog(...)
#endif

static id suspendLock;

@interface Supervisor ()
{
    NSPipe *pipe;
    NSTask *task;
    bool suspended;
}

- (void)start;

@end

@implementation Supervisor

- (id)init
{
    self = [super init];
    if (self != nil) {
        suspended = false;
    }
    return self;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    [self stop];
}


- (void)run
{
    [self initSupervisor];
    [self start];
}

- (void)rerun
{
    [self stop];
    [self run];
}

- (void)stop
{
    if ([task isRunning]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NSTaskDidTerminateNotification
                                                      object:task];
        if (suspended) {
            [task resume];
        }
        [task terminate];
    }
    [task waitUntilExit];
}


- (void)initSupervisor
{
    currentDirectoryPath = NSHomeDirectory();
    taskCommand = @"echo Supervisor";
    niceIncrement = 0;
}

- (void)start
{
    [self initPipe];
    [self initTask];
    [task launch];
}

- (void)toggle
{
    @synchronized(suspendLock) {
        if (suspended) {
            [task resume];
            suspended = false;
            DLog(@"task resume");
        } else {
            [task suspend];
            suspended = true;
            DLog(@"task suspend");
        }
    }
}

- (bool)isSuspend
{
    return suspended;
}

- (NSString *)escapeForShell:(NSString *)path
{
    return [path stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
}

- (void)initPipe
{
    pipe = [[NSPipe alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(readProgress:)
                                                 name:NSFileHandleReadCompletionNotification
                                               object:[pipe fileHandleForReading]];
    [[pipe fileHandleForReading] readInBackgroundAndNotify];
}

- (void)initTask
{
    task = [[NSTask alloc] init];
    [task setStandardOutput:pipe];
    [task setStandardError:pipe];
    [task setCurrentDirectoryPath:currentDirectoryPath];
    [task setLaunchPath: @"/bin/sh"];
    [task setArguments:[NSArray arrayWithObjects: @"-c",
                        [@"" stringByAppendingFormat:@"nice -n %d %@", niceIncrement, taskCommand],
                        nil]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didTerminate:)
                                                 name:NSTaskDidTerminateNotification
                                               object:task];
}

- (void)readProgress:(NSNotification *)notification
{
	NSData *data = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];

    if (data != nil && [data length])
    {
        DLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }

    if ( [task isRunning] ) {
        [[pipe fileHandleForReading] readInBackgroundAndNotify];
    }
}

- (void)didTerminate:(NSNotification *)notification
{
    DLog(@"task terminate");
    if ( ![task isRunning] ) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NSTaskDidTerminateNotification
                                                      object:task];
        [self start];
    }
}

@end
