//
//  FormmatterHelper.h
//  Cronometro
//
//  Created by Sandra Guzmán Bautista on 02/06/15.
//  Copyright (c) 2015 onikom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FormmatterHelper : NSObject

+ (NSDate *)convertStringToDate:(NSString *)string withFormat:(NSString *)format;
+ (NSString *)convertDateToString:(NSDate *)date withFormat:(NSString *)format;
+ (NSString *)getDateStringWithHour:(NSString *)hours  andMinutes:(NSString *)minutes andSeconds:(NSString *)seconds;
+ (NSString *)getDateFormat:(NSDate *)date;
+ (NSDateFormatter *)initializeNSDateFormat:(NSString *)format;
+ (int)convertDateToSeconds:(NSDate *)date;

@end
