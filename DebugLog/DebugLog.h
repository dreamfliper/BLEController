//
//  DebugLog.h
//  DebugLogRecordDemo
//
//  Created by shouian on 2014/1/19.
//  Copyright (c) 2014年 shouian. All rights reserved.
//

#import <Foundation/Foundation.h>

#define __DEBUG__

@interface DebugLog : NSObject

void BugLog (NSString *format, ...) NS_FORMAT_FUNCTION(1,2);

@end
