//
//  FormmatterHelper.m
//  Cronometro
//
//  Created by Sandra Guzmán Bautista on 02/06/15.
//  Copyright (c) 2015 onikom. All rights reserved.
//

#import "FormmatterHelper.h"
#import "Constants.h"

@implementation FormmatterHelper

+ (NSDate *)convertStringToDate:(NSString *)string withFormat:(NSString *)format {
    NSDate *date = [[self initializeNSDateFormat:format] dateFromString:string];
    
    return date;
}

+ (NSString *)convertDateToString:(NSDate *)date withFormat:(NSString *)format {
    NSString *stringFormat = [[self initializeNSDateFormat:format] stringFromDate:date];
    
    return stringFormat;
}

+ (NSString *)getDateStringWithHour:(NSString *)hours  andMinutes:(NSString *)minutes andSeconds:(NSString *)seconds {
    if ([hours isEqual:@""]) {
        hours = @"0";
    }
    
    if ([minutes isEqual:@""]) {
        minutes = @"0";
    }
    
    if ([seconds isEqual:@""]) {
        seconds = @"0";
    }
    
    NSString *date = [NSString stringWithFormat:@"%@:%@:%@", hours, minutes, seconds];
    return date;
}

+ (NSString *)getDateFormat:(NSDate *)date {
    NSString *format = @"";
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:date];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    
    if (hour != 0) {
        format = TYPEDEFS_FULLTIME;
    } else if (minute != 0) {
        format = TYPEDEFS_TIMEMMSS;
    } else {
        format = TYPEDEFS_TIMESS;
    }

    return format;
}


+ (NSDateFormatter *)initializeNSDateFormat:(NSString *)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    
    return formatter;
}

+ (int)convertDateToSeconds:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:date];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    NSInteger second = [components second];
    
    int seconds = (int)(hour * 3600);
    seconds += (int)(minute * 60);
    seconds += second;
    
    return seconds;
}

+ (BOOL)isValidIpAddress:(NSString *)ipAddress {
    struct sockaddr_in sa;
    int result = inet_pton(AF_INET, [ipAddress UTF8String], &(sa.sin_addr));
    return result != 0;
}

+ (NSArray *)getStringComponents:(NSString *)string withToken:(NSString *)token {
    NSArray* components = [[string stringByTrimmingCharactersInSet:
                            [NSCharacterSet whitespaceAndNewlineCharacterSet]]
                           componentsSeparatedByString:token];
    
    return components;
}

@end
