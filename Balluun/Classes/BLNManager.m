//
//  BLNManager.m
//  Balluun
//
//  Created by Jeremy Foo on 11/7/15.
//  Copyright © 2015 Ottoman. All rights reserved.
//

#import "BLNManager.h"

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
        _alertState = BLNAlertStateGreen;
        _locationScore = BLNAlertStateGreen;
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        _queue = [[NSOperationQueue alloc] init];
        
        _healthStore = [[HKHealthStore alloc] init];
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.activityType = CLActivityTypeOther;
        _locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        _locationManager.delegate = self;
        
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)
        {
            [_locationManager startMonitoringSignificantLocationChanges];
        }
        
        _motionManager = [[CMMotionActivityManager alloc] init];
        [_motionManager startActivityUpdatesToQueue:_queue withHandler:^(CMMotionActivity * __nullable activity) {
            _currentActivity = [activity copy];
        }];
        
        _loginState = BLNLoginStateLoggedOut;
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

- (void)setAlertState:(BLNAlertState)alertState
{
    if (_alertState != alertState)
    {
        _alertState = alertState;
        
        if (_alertState == BLNAlertStateDEFCON)
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
}

- (void)startDefconState
{
    [self setAlertState:BLNAlertStateDEFCON];
    // tell watch app that we need to start a workout session
    
}

- (void)stopDefconState
{
    [self setAlertState:BLNAlertStateGreen];
    [self updateServer];
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
    
    if (state == BLNAlertStateDEFCON)
    {
        // include other shit like heart rate
    }
    
    dict[BLNManagerJSONTimestampKey] = @([[NSDate date] timeIntervalSinceReferenceDate]);
    dict[BLNManagerJSONUserHashKey] = [[NSUUID UUID] UUIDString];
    
    return dict;
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
        [self.session dataTaskWithRequest:request completionHandler:^(NSData * __nullable data, NSURLResponse * __nullable response, NSError * __nullable error) {
            
        }];
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


@end
