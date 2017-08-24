//
//  DebugLog.m
//  DebugLogRecordDemo
//
//  Created by shouian on 2014/1/19.
//  Copyright (c) 2014年 shouian. All rights reserved.
//

#import "DebugLog.h"

static NSString *const directory = @"record";
static NSString *const logfile = @"record.txt";

#if __has_feature(objc_arc)
    #define AUTORELEASE(expression) expression
    #define RELEASE(expression) expression
#else
    #define AUTORELEASE(expression) [expression autorelease]
    #define RELEASE(expression) [expression release]
#endif

#define kMaxLineOfLog 1000

@implementation DebugLog

+ (id)sharedInstance
{
    DebugLog *debugLog = AUTORELEASE([DebugLog new]);
    
    return debugLog;
}

void BugLog(NSString *format, ...)
{
#ifdef __DEBUG__
    
    va_list args;
    va_start(args, format);
    NSString *newLog = [[NSString alloc] initWithFormat:format arguments:args];
    
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:SS"];
    
    NSString *dateString = [formatter stringFromDate:date];
    RELEASE(formatter);
    
    NSString *savedLog = [[DebugLog sharedInstance] readLogFile];
    savedLog = [savedLog stringByAppendingFormat:@"%@ %@\n", dateString, newLog];
    
    [[DebugLog sharedInstance] performSelector:@selector(writeLogFileWithLog:) withObject:savedLog];
    savedLog = nil;
    
    NSLog(@"%@", newLog);
    
    va_end(args);
    
    RELEASE(newLog);
    
#endif
}

#pragma mark - Read & Write Log information to File

- (NSString *)savedPath
{
    // Get Document Path
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [[path objectAtIndex:0]stringByAppendingPathComponent:@"fileName.txt"];
    
    // Get current date
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSString *dateOfString = @"";//[formatter stringFromDate:date];
    RELEASE(formatter);
    
    NSString *savedPath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@ %@", directory, dateOfString, logfile]];
    
    return savedPath;
}

- (BOOL)createDirectoryAtPath:(NSString *)path
{
    NSError *error = nil;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])    //Does directory already exist?
    {
        return NO;
    }
    
    if (![[NSFileManager defaultManager] createDirectoryAtPath:path
                                   withIntermediateDirectories:NO
                                                    attributes:nil
                                                         error:&error]){
        NSLog(@"%@", error);
        
        return NO; // Create failed
    }
    
    return YES;
}

- (NSString *)readLogFile
{
    NSString *savedPath = [self savedPath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:savedPath]) {
        NSError *error = nil;
        NSString *log = [NSString stringWithContentsOfFile:savedPath encoding:NSUTF8StringEncoding error:&error];
        
        if (error != nil) {
            NSLog(@"%@", error);
            return [NSString string];
        }
        
        return log;
    }
    
    [self createDirectoryAtPath:[savedPath stringByDeletingLastPathComponent]];
    
    return [NSString string];
}

- (BOOL)writeLogFileWithLog:(NSString *)log
{
    NSString *savedPath = [self savedPath];
    NSError *error = nil;
    [log writeToFile:savedPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    if (error != nil) {
        NSLog(@"%@", error);
        return NO;
    }
    
    return YES;
}


@end
