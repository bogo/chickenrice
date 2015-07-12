//
//  BLNManager.h
//  Balluun
//
//  Created by Jeremy Foo on 11/7/15.
//  Copyright © 2015 Ottoman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <HealthKit/HealthKit.h>
#import <CoreMotion/CoreMotion.h>

typedef NS_ENUM(NSUInteger, BLNAlertState) {
    BLNAlertStateGreen,
    BLNAlertStateOrange,
    BLNAlertStateRed,
    BLNAlertStateDEFCON
};

/**
 * Enum to describe the login states.
 */
typedef NS_ENUM(NSUInteger, BLNGlobalLoginState) {
    BLNGlobalLoginStateLoggedOut,
    BLNGlobalLoginStateLoggedIn,
};

extern NSString *const BLNManagerJSONLocationKey;
extern NSString *const BLNManagerJSONHeadingKey;
extern NSString *const BLNManagerJSONActivityKey;
extern NSString *const BLNManagerJSONTimestampKey;
extern NSString *const BLNManagerJSONUserHashKey;

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

@interface BLNManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong, readonly) NSURLSession *session;
@property (nonatomic, strong, readonly) NSOperationQueue *queue;

// internal managers
@property (nonatomic, strong, readonly) CMMotionActivityManager *motionManager;
@property (nonatomic, strong, readonly) CLLocationManager *locationManager;
@property (nonatomic, strong, readonly) HKHealthStore *healthStore;

//properties
@property (nonatomic, assign, readonly) BLNAlertState alertState;
@property (nonatomic, copy, readonly) CMMotionActivity *currentActivity;
@property (nonatomic, copy, readonly) CLLocation *currentLocation;
@property (nonatomic, copy, readonly) CLHeading *currentHeading;
@property (nonatomic, assign, readonly) BLNAlertState locationScore;

@property (nonatomic, assign, readonly) BLNGlobalLoginState loginState;

+ (instancetype)sharedInstance;

- (void)startDefconState;
- (void)stopDefconState;
- (void)requestPermissions;

@end
