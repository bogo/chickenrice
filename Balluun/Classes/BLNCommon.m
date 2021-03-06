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

NSString *const BLNManagerJSONBiometricHeartRateKey = @"heart-rate";

NSString *const BLNManagerJSONTimestampKey = @"timestamp";
NSString *const BLNManagerJSONUserHashKey = @"user-hash";
NSString *const BLNManagerJSONUsernameKey = @"name";
NSString *const BLNManagerJSONPhonenumberKey = @"number";
NSString *const BLNManagerJSONAlertStateKey = @"alert-state";

NSString *const BLNManagerBalloonIndexKey = @"balloons";
NSString *const BLNManagerCurrentAlertStateKey = @"current-alert-state";

#pragma mark - Messages

NSString *const BLNMessagePanicType = @"shit really hit the fan";
NSString *const BLNMessagePANICINTHEDISCOType = @"panic!";
NSString *const BLNMessageCheerioType = @"phew!";
NSString *const BLNMessageBiometricsUpdateType = @"biometric-update";
NSString *const BLNMessageRequestLatestStateType = @"latest-state-plz";
NSString *const BLNMessageUpdateComplicationType = @"update-complication-plz";
NSString *const BLNMessageTimeStampKey = @"timestamp";

NSString *const BLNManagerMessagePayloadTypeKey = @"type";
NSString *const BLNManagerMessagePayloadDataKey = @"data";

NSString *const BLMMessageBiometericSamplesKey = @"samples";
NSString *const BLMMessageBiometricHeartRateKey = @"heart-rate";
NSString *const BLMMessageBiometricStartDateKey = @"biometric-start-date";
NSString *const BLMMessageBiometricEndDateKey = @"biometric-end-date";

@implementation BLNCommon

#pragma mark - Messaging

+ (NSDictionary *)messageUserInfoForType:(NSString *)type payload:(NSDictionary *)dict
{
    NSParameterAssert(type);
    NSMutableDictionary *messageDict = [NSMutableDictionary dictionaryWithDictionary:@{BLNManagerMessagePayloadTypeKey: type}];
    if (dict)
    {
        messageDict[BLNManagerMessagePayloadDataKey] = dict;
    }
    
    return messageDict;
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
