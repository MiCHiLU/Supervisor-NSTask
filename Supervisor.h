//
//  Supervisor.h
//  Supervisor-NSTask
//
//  Created by ENDOH takanao on 11/13/13.
//  Copyright (c) 2013 ENDOH takanao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Supervisor : NSObject <NSApplicationDelegate>
{
    NSString *currentDirectoryPath;
    NSString *taskCommand;
    int niceIncrement;
}

- (void)initSupervisor;
- (void)run;
- (void)rerun;
- (void)toggle;
- (bool)isSuspend;
- (NSString *)escapeForShell:(NSString *)path;

@end
