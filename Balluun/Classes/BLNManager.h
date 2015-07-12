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
#import <WatchConnectivity/WatchConnectivity.h>
#import "BLNCommon.h"

/**
 * Enum to describe the login states.
 */
typedef NS_ENUM(NSUInteger, BLNLoginState) {
    BLNLoginStateLoggedOut,
    BLNLoginStateLoggedIn,
};

@protocol BLNManagerObserver;

@interface BLNManager : NSObject <CLLocationManagerDelegate, WCSessionDelegate>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *phoneNumber;

@property (nonatomic, strong, readonly) NSURLSession *session;
@property (nonatomic, strong, readonly) NSOperationQueue *queue;

// internal managers
@property (nonatomic, strong, readonly) WCSession *watchSession;
@property (nonatomic, strong, readonly) CMMotionActivityManager *motionManager;
@property (nonatomic, strong, readonly) CLLocationManager *locationManager;
@property (nonatomic, strong, readonly) HKHealthStore *healthStore;

//properties
@property (nonatomic, assign, readonly) BLNAlertState currentAlertState;
@property (nonatomic, assign, readonly) BLNAlertState currentLocationScore;
@property (nonatomic, copy, readonly) NSDate *currentLocationScoreTimestamp;

@property (nonatomic, copy, readonly) NSNumber *currentHeartRate;
@property (nonatomic, copy, readonly) CMMotionActivity *currentActivity;
@property (nonatomic, copy, readonly) CLLocation *currentLocation;
@property (nonatomic, copy, readonly) CLHeading *currentHeading;

@property (nonatomic, assign, readonly) BLNLoginState loginState;

+ (instancetype)sharedInstance;

- (void)startDefconState;
- (void)panic;
- (void)stopDefconState;

- (void)requestPermissions;
- (void)updateWatch;
- (void)updateServer;

- (void)login;

#pragma mark - OBSERVE THINGS

- (void)addObserver:(id<BLNManagerObserver>)observer;
- (void)removeObserver:(id<BLNManagerObserver>)observer;

@end

@protocol BLNManagerObserver <NSObject>

@optional
- (void)manager:(BLNManager *)manager changedLocationStateTo:(BLNAlertState)alertState;
- (void)manager:(BLNManager *)manager changedAlertStateTo:(BLNAlertState)alertState;
- (void)manager:(BLNManager *)manager changedBPMTo:(double)bpm;

@end