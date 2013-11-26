//
//  AppDelegate.m
//  Supervisor-NSTask
//
//  Created by ENDOH takanao on 10/7/13.
//  Copyright (c) 2013 ENDOH takanao. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
{
    NSString *destinationDirectoryPath;
}

@property (weak) IBOutlet NSMenuItem *statusToggle;
- (IBAction)Toggle:(id)sender;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self run];
}

- (void)initSupervisor
{
    NSString *currentDirectoryPathSuffix = @"/Documents";
    currentDirectoryPath = [NSHomeDirectory() stringByAppendingString:currentDirectoryPathSuffix];
    taskCommand = [[self escapeForShell:[[[NSBundle mainBundle] resourcePath]
                                         stringByAppendingPathComponent:@"example"]]
                   stringByAppendingString:[@" " @"options"]];
    niceIncrement = 0;
}

- (IBAction)Toggle:(id)sender {
    [self toggle];
    if ([self isSuspend]) {
        _statusToggle.title = @"Resume";
    } else {
        _statusToggle.title = @"Suspend";
    }
}

@end

