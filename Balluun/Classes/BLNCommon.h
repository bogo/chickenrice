//
//  BLNCommon.h
//  Balluun
//
//  Created by Jeremy Foo on 11/7/15.
//  Copyright © 2015 Ottoman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLNAlertState.h"

#pragma mark - JSON

extern NSString *const BLNManagerJSONLocationKey;
extern NSString *const BLNManagerJSONHeadingKey;
extern NSString *const BLNManagerJSONActivityKey;
extern NSString *const BLNManagerJSONTimestampKey;
extern NSString *const BLNManagerJSONUserHashKey;
extern NSString *const BLNManagerJSONAlertStateKey;
extern NSString *const BLNManagerJSONUsernameKey;

extern NSString *const BLNManagerJSONLocationLatitudeKey;
extern NSString *const BLNManagerJSONLocationLongitudeKey;
extern NSString *const BLNManagerJSONLocationHorizontalAccuracyKey;
extern NSString *const BLNManagerJSONLocationVerticalAccuracyKey;
extern NSString *const BLNManagerJSONLocationAltitudeKey;
extern NSString *const BLNManagerJSONLocationTimestampKey;
extern NSString *const BLNManagerJSONLocationSpeedKey;
extern NSString *const BLNManagerJSONLocationDirectionKey;

extern NSString *const BLNManagerJSONHeadingMagneticKey;
extern NSString *const BLNManagerJSONHeadingTrueKey;
extern NSString *const BLNManagerJSONHeadingAccuracyKey;
extern NSString *const BLNManagerJSONHeadingTimestampKey;

extern NSString *const BLNManagerJSONActivityTypeKey;
extern NSString *const BLNManagerJSONActivityConfidenceKey;
extern NSString *const BLNManagerJSONActivityStartTimestampKey;

extern NSString *const BLNManagerJSONBiometricHeartRateKey;

extern NSString *const BLNManagerBalloonIndexKey;

#pragma mark - Messaging

extern NSString *const BLNMessagePanicType;
extern NSString *const BLNMessageRequestLatestStateType;
extern NSString *const BLNMessageUpdateComplicationType;
extern NSString *const BLNMessagePANICINTHEDISCOType;
extern NSString *const BLNMessageCheerioType;
extern NSString *const BLNMessageBiometricsUpdateType;
extern NSString *const BLNMessageTimeStampKey;

#pragma mark - Biometric

extern NSString *const BLMMessageBiometericSamplesKey;
extern NSString *const BLMMessageBiometricHeartRateKey;
extern NSString *const BLMMessageBiometricStartDateKey;
extern NSString *const BLMMessageBiometricEndDateKey;

@interface BLNCommon : NSObject

+ (NSDictionary *)messageUserInfoForType:(NSString *)type payload:(NSDictionary *)dict;
+ (NSString *)typeForMessageUserInfo:(NSDictionary *)userInfo;
+ (NSDictionary *)payloadForMessageUserInfo:(NSDictionary *)userInfo;

@end
