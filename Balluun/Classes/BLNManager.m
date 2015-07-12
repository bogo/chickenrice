//
//  BLNManager.m
//  Balluun
//
//  Created by Jeremy Foo on 11/7/15.
//  Copyright © 2015 Ottoman. All rights reserved.
//

#import "BLNManager.h"

#define PANIC_URL @"http://chickenrice-112258.nitrousapp.com:3000/panic"
#define PING_URL @"http://chickenrice-112258.nitrousapp.com:3000/ping"

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
        _currentLocationScoreTimestamp = [NSDate date];
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
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateServer) object:nil];

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
    else if (_currentAlertState < BLNAlertStateRed)
    {
        [self.locationManager stopUpdatingHeading];
        [self.locationManager stopUpdatingLocation];
        [self.locationManager startMonitoringSignificantLocationChanges];
    }
}

- (void)startDefconState
{
    [self setCurrentAlertState:BLNAlertStateDEFCON];    
}

- (void)panic
{
    [self setCurrentAlertState:BLNAlertStatePanicked];
    
    NSDictionary *dict = [self JSONDictionaryForState:self.currentAlertState];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    if (jsonData)
    {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:PANIC_URL]];
        request.HTTPMethod = @"POST";
        request.HTTPBody = jsonData;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateServer) object:nil];
        
        [[self.session dataTaskWithRequest:request completionHandler:^(NSData * __nullable data, NSURLResponse * __nullable response, NSError * __nullable error) {
            if (self.currentAlertState >= BLNAlertStateRed)
            {
                [self performSelector:@selector(updateServer) withObject:nil afterDelay:(self.currentAlertState == BLNAlertStateDEFCON) ? 15 : 45];
            }
            
            if (!error)
            {
                NSLog(@"Error pinging server :( %@", error);
                return;
            }
            
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            BLNAlertState locationScore = [[jsonDict objectForKey:@"score"] unsignedIntegerValue];
            
            if (locationScore != self.currentLocationScore)
            {
                _currentLocationScore = locationScore;
                _currentLocationScoreTimestamp = [NSDate date];
                [self updateWatch];
            }
            
        }] resume];
    }
    else
    {
        NSLog(@"OH NOES WE CANNOT SEND SERVER UPDATE! %@", error);
    }
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
    
    if (state >= BLNAlertStateRed)
    {
        // include heartrate
        if (self.currentHeartRate)
        {
            dict[BLNManagerJSONBiometricHeartRateKey] = self.currentHeartRate;
        }
    }
    
    if (state >= BLNAlertStateDEFCON)
    {
        // include audio
    }
    
    if (state == BLNAlertStatePanicked)
    {
        // include name
        dict[BLNManagerJSONUsernameKey] = @"Jason";
    }
    
    dict[BLNManagerJSONAlertStateKey] = @(self.currentAlertState);
    dict[BLNManagerJSONTimestampKey] = @([[NSDate date] timeIntervalSinceReferenceDate]);
    dict[BLNManagerJSONUserHashKey] = [[NSUUID UUID] UUIDString];
    
    return dict;
}

#pragma mark - Update Components

- (void)updateWatch
{
    NSDictionary *context = @{BLNManagerBalloonIndexKey: @(self.currentLocationScore), BLNMessageTimeStampKey: @([self.currentLocationScoreTimestamp timeIntervalSinceReferenceDate])};
    [self.watchSession updateApplicationContext:context error:nil];
    [self.watchSession transferCurrentComplicationUserInfo:context];
}

- (void)updateServer
{
    NSDictionary *dict = [self JSONDictionaryForState:self.currentAlertState];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    if (jsonData)
    {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:PING_URL]];
        request.HTTPMethod = @"POST";
        request.HTTPBody = jsonData;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateServer) object:nil];

        [[self.session dataTaskWithRequest:request completionHandler:^(NSData * __nullable data, NSURLResponse * __nullable response, NSError * __nullable error) {
            if (self.currentAlertState >= BLNAlertStateRed)
            {
                [self performSelector:@selector(updateServer) withObject:nil afterDelay:(self.currentAlertState == BLNAlertStateDEFCON) ? 15 : 45];
            }
            
            if (error)
            {
                NSLog(@"Error pinging server :( %@", error);
                return;
            }
            
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            double serverScore = [[jsonDict objectForKey:@"score"] floatValue];
            BLNAlertState locationScore = (NSUInteger)round(1.0 / BLNAlertStateRed / serverScore);
            
            if (locationScore != self.currentLocationScore)
            {
                _currentLocationScore = locationScore;
                _currentLocationScoreTimestamp = [NSDate date];
                [self updateWatch];
            }
            
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
        [observer manager:self changedAlertStateTo:newAlertState];
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
    [self updateWatch];
}

/** Called when the reachable state of the counterpart app changes. The receiver should check the reachable property on receiving this delegate callback. */
- (void)sessionReachabilityDidChange:(WCSession *)session
{
    [self updateWatch];
}

/** Called on the delegate of the receiver. Will be called on startup if the incoming message caused the receiver to launch. */
- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message
{
    NSAssert(NO, @"WE SHOULD ALWAYS HAVE A REPLY HANDLER!");
}

/** Called on the delegate of the receiver when the sender sends a message that expects a reply. Will be called on startup if the incoming message caused the receiver to launch. */
- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message replyHandler:(void(^)(NSDictionary<NSString *, id> *replyMessage))replyHandler
{
    NSString *type = [BLNCommon typeForMessageUserInfo:message];
    NSDictionary *payload = [BLNCommon payloadForMessageUserInfo:message];
    if ([type isEqualToString:BLNMessageRequestLatestStateType])
    {
        replyHandler(@{BLNManagerBalloonIndexKey: @(self.currentLocationScore), BLNMessageTimeStampKey: @([self.currentLocationScoreTimestamp timeIntervalSinceReferenceDate])});
    }
    
    if ([type isEqualToString:BLNMessageBiometricsUpdateType])
    {
        NSDictionary *latestSample = [[payload objectForKey:BLMMessageBiometericSamplesKey] lastObject];
        _currentHeartRate = [latestSample objectForKey:BLMMessageBiometricHeartRateKey];
        [self updateServer];
        replyHandler(nil);
    }
    
    if ([type isEqualToString:BLNMessagePANICINTHEDISCOType])
    {
        [self setCurrentAlertState:BLNAlertStateDEFCON];
    }
    
    if ([type isEqualToString:BLNMessageCheerioType])
    {
        [self setCurrentAlertState:BLNAlertStateGreen];
    }
    
    if ([type isEqualToString:BLNMessagePanicType])
    {
        [self panic];
    }
}

@end
