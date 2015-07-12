//
//  BLNCommon.m
//  Balluun
//
//  Created by Jeremy Foo on 11/7/15.
//  Copyright © 2015 Ottoman. All rights reserved.
//

#import "BLNCommon.h"

#pragma mark - JSON

NSString *const BLNManagerJSONLocationKey = @"gps";
NSString *const BLNManagerJSONLocationLatitudeKey = @"latitude";
NSString *const BLNManagerJSONLocationLongitudeKey = @"longitude";
NSString *const BLNManagerJSONLocationHorizontalAccuracyKey = @"vertical-accuracy";
NSString *const BLNManagerJSONLocationVerticalAccuracyKey = @"horizontal-accuracy";
NSString *const BLNManagerJSONLocationAltitudeKey = @"altitude";
NSString *const BLNManagerJSONLocationTimestampKey = @"timestamp";
NSString *const BLNManagerJSONLocationSpeedKey = @"speed";
NSString *const BLNManagerJSONLocationDirectionKey = @"direction";

NSString *const BLNManagerJSONHeadingKey = @"heading";
NSString *const BLNManagerJSONHeadingMagneticKey = @"magnetic";
NSString *const BLNManagerJSONHeadingTrueKey = @"true";
NSString *const BLNManagerJSONHeadingAccuracyKey = @"accuracy";
NSString *const BLNManagerJSONHeadingTimestampKey = @"timestamp";

NSString *const BLNManagerJSONActivityKey = @"activity";
NSString *const BLNManagerJSONActivityTypeKey = @"type";
NSString *const BLNManagerJSONActivityConfidenceKey = @"confidence";
NSString *const BLNManagerJSONActivityStartTimestampKey = @"startTimestamp";

NSString *const BLNManagerJSONTimestampKey = @"timestamp";
NSString *const BLNManagerJSONUserHashKey = @"user";
NSString *const BLNManagerJSONAlertStateKey = @"alert-state";

NSString *const BLNManagerBalloonIndexKey = @"balloons";

#pragma mark - Messages

NSString *const BLNMessageRequestLatestStateType = @"latest-state-plz";
NSString *const BLNMessageUpdateCompliactionType = @"update-complication-plz";

NSString *const BLNManagerMessagePayloadTypeKey = @"type";
NSString *const BLNManagerMessagePayloadDataKey = @"data";

@implementation BLNCommon

#pragma mark - Messaging

+ (NSDictionary *)messageUserInfoForType:(NSString *)type payload:(NSDictionary *)dict
{
    NSParameterAssert(type);
    NSParameterAssert(dict);
    
    return @{BLNManagerMessagePayloadTypeKey: type, BLNManagerMessagePayloadDataKey: dict};
}

+ (NSString *)typeForMessageUserInfo:(NSDictionary *)userInfo
{
    return [userInfo objectForKey:BLNManagerMessagePayloadTypeKey];
}

+ (NSDictionary *)payloadForMessageUserInfo:(NSDictionary *)userInfo
{
    return [userInfo objectForKey:BLNManagerMessagePayloadDataKey];
}

@end
