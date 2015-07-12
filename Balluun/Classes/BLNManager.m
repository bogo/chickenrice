//
//  BLNManager.m
//  Balluun
//
//  Created by Jeremy Foo on 11/7/15.
//  Copyright © 2015 Ottoman. All rights reserved.
//

#import "BLNManager.h"

@interface BLNManager ()

@property (nonatomic, strong) NSHashTable *observers;

@end

@implementation BLNManager

+ (instancetype)sharedInstance
{
    static BLNManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[BLNManager alloc] init];
    });
    
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _currentAlertState = BLNAlertStateGreen;
        _currentLocationScore = BLNAlertStateGreen;
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        _queue = [[NSOperationQueue alloc] init];
        
        _healthStore = [[HKHealthStore alloc] init];
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.activityType = CLActivityTypeOther;
        _locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        _locationManager.delegate = self;
        
        if ([WCSession isSupported])
        {
            _watchSession = [WCSession defaultSession];
            _watchSession.delegate = self;
            [_watchSession activateSession];
        }
        
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)
        {
            [_locationManager startMonitoringSignificantLocationChanges];
        }
        
        _motionManager = [[CMMotionActivityManager alloc] init];
        [_motionManager startActivityUpdatesToQueue:_queue withHandler:^(CMMotionActivity * __nullable activity) {
            _currentActivity = [activity copy];
        }];
        
        _loginState = BLNLoginStateLoggedOut;
        _observers = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

- (void)requestPermissions
{
    if ([CLLocationManager authorizationStatus] < kCLAuthorizationStatusAuthorizedAlways)
    {
        [self.locationManager requestAlwaysAuthorization];
    }

    HKQuantityType *heartRateType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    if ([self.healthStore authorizationStatusForType:heartRateType])
    {
        [self.healthStore requestAuthorizationToShareTypes:nil readTypes:[NSSet setWithObject:heartRateType] completion:^(BOOL success, NSError * __nullable error) {
            if (!success)
            {
                NSLog(@"Error requesting heart rate authorization from healthkit: %@", error);
            }
        }];
    }
}

#pragma mark - Defcon

- (void)setCurrentAlertState:(BLNAlertState)currentAlertState
{
    if (_currentAlertState == currentAlertState)
    {
        return;
    }
    
    if (_currentAlertState == BLNAlertStateDEFCON && currentAlertState != BLNAlertStateGreen)
    {
        return;
    }

    _currentAlertState = currentAlertState;
    [self notifyObserversAboutAlertStateChangeTo:_currentAlertState];

    if (_currentAlertState == BLNAlertStateDEFCON)
    {
        self.locationManager.activityType = CLActivityTypeFitness;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        self.locationManager.pausesLocationUpdatesAutomatically = NO;
        [self.locationManager startUpdatingLocation];
        [self.locationManager startUpdatingHeading];

    }
    else
    {
        [self.locationManager stopUpdatingHeading];
        [self.locationManager stopUpdatingLocation];
        [self.locationManager startMonitoringSignificantLocationChanges];
    }
}

- (void)startDefconState
{
    [self setCurrentAlertState:BLNAlertStateDEFCON];
    // tell watch app that we need to start a workout session
    
}

- (void)stopDefconState
{
    [self setCurrentAlertState:BLNAlertStateGreen];
}

#pragma mark - Server based breadcrumb

- (NSDictionary *)JSONDictionaryForState:(BLNAlertState)state
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:9];
    if (self.currentLocation)
    {
        NSMutableDictionary *locationDict = [NSMutableDictionary dictionaryWithCapacity:8];
        locationDict[BLNManagerJSONLocationLongitudeKey] = @(self.currentLocation.coordinate.longitude);
        locationDict[BLNManagerJSONLocationLatitudeKey] = @(self.currentLocation.coordinate.latitude);
        locationDict[BLNManagerJSONLocationAltitudeKey] = @(self.currentLocation.altitude);
        locationDict[BLNManagerJSONLocationSpeedKey] = @(self.currentLocation.speed);
        locationDict[BLNManagerJSONLocationHorizontalAccuracyKey] = @(self.currentLocation.horizontalAccuracy);
        locationDict[BLNManagerJSONLocationVerticalAccuracyKey] = @(self.currentLocation.verticalAccuracy);
        locationDict[BLNManagerJSONLocationTimestampKey]= @([self.currentLocation.timestamp timeIntervalSinceReferenceDate]);
        locationDict[BLNManagerJSONLocationDirectionKey] = @(self.currentLocation.course);
        dict[BLNManagerJSONLocationKey] = locationDict;
    }
    
    if (self.currentHeading)
    {
        NSMutableDictionary *headingDict = [NSMutableDictionary dictionaryWithCapacity:4];
        headingDict[BLNManagerJSONHeadingTrueKey] = @(self.currentHeading.trueHeading);
        headingDict[BLNManagerJSONHeadingMagneticKey] = @(self.currentHeading.magneticHeading);
        headingDict[BLNManagerJSONHeadingTimestampKey] = @([self.currentHeading.timestamp timeIntervalSinceReferenceDate]);
        headingDict[BLNManagerJSONHeadingAccuracyKey] = @(self.currentHeading.headingAccuracy);
        dict[BLNManagerJSONHeadingKey] = headingDict;
    }
    
    if (self.currentActivity)
    {
        NSMutableDictionary *activityDict = [NSMutableDictionary dictionaryWithCapacity:3];
        activityDict[BLNManagerJSONActivityStartTimestampKey] = @([self.currentActivity.startDate timeIntervalSinceReferenceDate]);
        activityDict[BLNManagerJSONActivityConfidenceKey] = @(self.currentActivity.confidence);
        
        NSString *type = @"unknown";
        type = (self.currentActivity.stationary) ? @"stationary" : type;
        type = (self.currentActivity.cycling) ? @"walking" : type;
        type = (self.currentActivity.cycling) ? @"running" : type;
        type = (self.currentActivity.cycling) ? @"automative" : type;
        type = (self.currentActivity.cycling) ? @"cycling" : type;
        
        dict[BLNManagerJSONActivityTypeKey] = type;
        
        dict[BLNManagerJSONActivityKey] = activityDict;
    }
    
    if (state == BLNAlertStateRed)
    {
        // include heartrate
    }
    
    if (state == BLNAlertStateDEFCON)
    {
        // include audio
    }
    
    dict[BLNManagerJSONAlertStateKey] = @(self.currentAlertState);
    dict[BLNManagerJSONTimestampKey] = @([[NSDate date] timeIntervalSinceReferenceDate]);
    dict[BLNManagerJSONUserHashKey] = [[NSUUID UUID] UUIDString];
    
    return dict;
}

#pragma mark - Update Components

- (void)updateWatch
{
    [self.watchSession transferCurrentComplicationUserInfo:@{BLNManagerBalloonIndexKey: @(self.currentLocationScore)}];
}

- (void)updateServer
{
    NSDictionary *dict = [self JSONDictionaryForState:BLNAlertStateGreen];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    if (jsonData)
    {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@""]];
        request.HTTPMethod = @"POST";
        request.HTTPBody = jsonData;
        [[self.session dataTaskWithRequest:request completionHandler:^(NSData * __nullable data, NSURLResponse * __nullable response, NSError * __nullable error) {
            if (!error)
            {
                NSLog(@"Error pinging server :( %@", error);
                return;
            }
            
            [self updateWatch];
        }] resume];
    }
    else
    {
        NSLog(@"OH NOES WE CANNOT SEND SERVER UPDATE! %@", error);
    }
}

#pragma mark - Location

- (void)locationManager:(nonnull CLLocationManager *)manager didUpdateHeading:(nonnull CLHeading *)newHeading
{
    _currentHeading = newHeading;
    [self updateServer];
}

- (void)locationManager:(nonnull CLLocationManager *)manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations
{
    _currentLocation = [locations lastObject];
    [self updateServer];
    
    // fetch latest score and update things
}

- (void)locationManager:(nonnull CLLocationManager *)manager didFailWithError:(nonnull NSError *)error
{
    NSLog(@"HAHA WE FAILED BUT SO WHAT?! %@", error);
}

- (void)locationManager:(nonnull CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedAlways)
    {
        [self.locationManager startMonitoringSignificantLocationChanges];
    }
}

#pragma mark - Login

- (void)login
{
    _loginState = BLNLoginStateLoggedIn;
}

#pragma mark - Observation

- (void)addObserver:(id<BLNManagerObserver>)observer
{
    NSParameterAssert(observer != nil);
    if (observer == nil) {
        return;
    }
    [self.observers addObject:observer];
}

- (void)removeObserver:(id<BLNManagerObserver>)observer
{
    NSParameterAssert(observer != nil);
    if (observer == nil) {
        return;
    }
    
    [self.observers removeObject:observer];
}
     
- (void)notifyObserversAboutAlertStateChangeTo:(BLNAlertState)newAlertState
{
    for (id<BLNManagerObserver> observer in self.observers.allObjects) {
        if (![observer respondsToSelector:@selector(manager:changedAlertStateTo:)]) {
            continue;
        }
        [observer manager:self
      changedAlertStateTo:newAlertState];
    }
}

#pragma mark - Watch

- (BOOL)isWatchReady
{
    return self.watchSession.isWatchAppInstalled && self.watchSession.isPaired;
}

/** Called when any of the Watch state properties change */
- (void)sessionWatchStateDidChange:(nonnull WCSession *)session
{

}

/** Called when the reachable state of the counterpart app changes. The receiver should check the reachable property on receiving this delegate callback. */
- (void)sessionReachabilityDidChange:(WCSession *)session
{
    
}

/** Called on the delegate of the receiver. Will be called on startup if the incoming message caused the receiver to launch. */
- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message
{
}

/** Called on the delegate of the receiver when the sender sends a message that expects a reply. Will be called on startup if the incoming message caused the receiver to launch. */
- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message replyHandler:(void(^)(NSDictionary<NSString *, id> *replyMessage))replyHandler
{
    NSString *type = [BLNCommon typeForMessageUserInfo:message];
    if ([type isEqualToString:BLNMessageRequestLatestStateType])
    {
        replyHandler(@{BLNManagerBalloonIndexKey: @(self.currentLocationScore)});
    }
}

/** Called on the delegate of the receiver. Will be called on startup if the incoming message data caused the receiver to launch. */
- (void)session:(WCSession *)session didReceiveMessageData:(NSData *)messageData
{
    
}

/** Called on the delegate of the receiver when the sender sends message data that expects a reply. Will be called on startup if the incoming message data caused the receiver to launch. */
- (void)session:(WCSession *)session didReceiveMessageData:(NSData *)messageData replyHandler:(void(^)(NSData *replyMessageData))replyHandler
{
    
}


/** -------------------------- Background Transfers ------------------------- */

/** Called on the delegate of the receiver. Will be called on startup if an applicationContext is available. */
- (void)session:(WCSession *)session didReceiveApplicationContext:(NSDictionary<NSString *, id> *)applicationContext
{
    
}

/** Called on the sending side after the user info transfer has successfully completed or failed with an error. Will be called on next launch if the sender was not running when the user info finished. */
- (void)session:(WCSession * __nonnull)session didFinishUserInfoTransfer:(WCSessionUserInfoTransfer *)userInfoTransfer error:(nullable NSError *)error
{
    
}

/** Called on the delegate of the receiver. Will be called on startup if the user info finished transferring when the receiver was not running. */
- (void)session:(WCSession *)session didReceiveUserInfo:(NSDictionary<NSString *, id> *)userInfo
{
    
}

/** Called on the sending side after the file transfer has successfully completed or failed with an error. Will be called on next launch if the sender was not running when the transfer finished. */
- (void)session:(WCSession *)session didFinishFileTransfer:(WCSessionFileTransfer *)fileTransfer error:(nullable NSError *)error
{
    
}

/** Called on the delegate of the receiver. Will be called on startup if the file finished transferring when the receiver was not running. The incoming file will be located in the Documents/Inbox/ folder when being delivered. The receiver must take ownership of the file by moving it to another location. The system will remove any content that has not been moved when this delegate method returns. */
- (void)session:(WCSession *)session didReceiveFile:(WCSessionFile *)file
{
    
}

@end
