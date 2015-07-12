//
//  BLNDirectReport.m
//  Balluun
//
//  Created by Jeremy Foo on 11/7/15.
//  Copyright © 2015 Ottoman. All rights reserved.
//

#import "BLNDirectReport.h"
#import <HealthKit/HealthKit.h>
#import <ClockKit/ClockKit.h>

NSString *const BLNDirectReportStateChangedNotification = @"BLNDirectReportStateChangedNotification";

@implementation _BLNBallonIndexItem
- (instancetype)initWithBalloonMessageUserInfo:(NSDictionary *)ballonUserInfo
{
    self = [super init];
    if (self)
    {
        _alertState = [[ballonUserInfo objectForKey:BLNManagerBalloonIndexKey] unsignedIntegerValue];
        _timestamp = [NSDate dateWithTimeIntervalSinceNow:[[ballonUserInfo objectForKey:BLNMessageTimeStampKey] doubleValue]];
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object])
    {
        return NO;
    }
    
    if (self.alertState != [(_BLNBallonIndexItem *)object alertState])
    {
        return NO;
    }
    
    if ([self.timestamp isEqualToDate:[(_BLNBallonIndexItem *)object timestamp]])
    {
        return NO;
    }
    
    return YES;
}
@end

@interface BLNDirectReport () <HKWorkoutSessionDelegate>
@property (nonatomic, strong) HKAnchoredObjectQuery *panicSessionBiometricQuery;
@property (nonatomic, strong) NSDate *panicSessionStartDate;
@property (nonatomic, strong) HKWorkoutSession *panicSession;
@property (nonatomic, strong) HKHealthStore *healthStore;
@end

@implementation BLNDirectReport

+ (instancetype)sharedInstance
{
    static BLNDirectReport *report = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        report = [[BLNDirectReport alloc] init];
    });
    return report;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _watchSession = [WCSession defaultSession];
        _watchSession.delegate = self;
        [_watchSession activateSession];
        
        _healthStore = [[HKHealthStore alloc] init];
        
        _ballonIndexItems = [NSMutableSet setWithCapacity:0];
    }
    return self;
}

#pragma mark - Workout (ahahahaha)

- (void)workoutSession:(nonnull HKWorkoutSession *)workoutSession didFailWithError:(nonnull NSError *)error
{
    
}

- (void)workoutSession:(nonnull HKWorkoutSession *)workoutSession didChangeToState:(HKWorkoutSessionState)toState fromState:(HKWorkoutSessionState)fromState date:(nonnull NSDate *)date
{
    switch (toState) {
        case HKWorkoutSessionStateRunning:
        {
            _panicSessionStartDate = date;
            
            HKSampleType *sampleType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
            _panicSessionBiometricQuery = [[HKAnchoredObjectQuery alloc] initWithType:sampleType predicate:nil anchor:HKAnchoredObjectQueryNoAnchor limit:HKObjectQueryNoLimit resultsHandler:^(HKAnchoredObjectQuery * __nonnull query, NSArray<__kindof HKSample *> * __nullable sampleObjects, NSArray<HKDeletedObject *> * __nullable deletedObjects, NSInteger newAnchor, NSError * __nullable error) {
                if (!sampleObjects)
                {
                    return;
                }
                
                NSMutableArray *samples = [NSMutableArray arrayWithCapacity:[sampleObjects count]];
                
                for (HKSample *sample in sampleObjects)
                {
                    if ([sample isKindOfClass:[HKQuantitySample class]])
                    {
                        HKQuantitySample *heartBeatSample = (HKQuantitySample *)sample;
                        
                        // bpm
                        double bpm = [[heartBeatSample quantity] doubleValueForUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]];
                        [samples addObject:@{BLMMessageBiometricHeartRateKey: @(bpm),
                                             BLMMessageBiometricStartDateKey: @([heartBeatSample.startDate timeIntervalSinceReferenceDate]),
                                             BLMMessageBiometricEndDateKey: @([heartBeatSample.endDate timeIntervalSinceReferenceDate])}];
                    }
                }
                
                NSDictionary *messageDictionary = [BLNCommon messageUserInfoForType:BLNMessageBiometricsUpdateType payload:@{BLMMessageBiometericSamplesKey: samples}];
                [self.watchSession sendMessage:messageDictionary replyHandler:^(NSDictionary<NSString *,id> * __nonnull replyMessage) {
                    NSLog(@"Successfully sent biometeric update!");
                } errorHandler:^(NSError * __nonnull error) {
                    NSLog(@"Error sending biometric update: %@", error);
                }];
            }];
            
            [self.healthStore executeQuery:self.panicSessionBiometricQuery];
            
        }
            break;
        case HKWorkoutSessionStateEnded:
            [self.healthStore stopQuery:self.panicSessionBiometricQuery];
            _panicSession = nil;
            _panicSessionBiometricQuery = nil;
            break;
            
        case HKWorkoutSessionStateNotStarted:
        default:
            break;
    }
}

#pragma mark - State

- (void)startDefconState
{
    _panicSession = [[HKWorkoutSession alloc] initWithActivityType:HKWorkoutActivityTypeWalking locationType:HKWorkoutSessionLocationTypeOutdoor];
    _panicSession.delegate = self;
    
    [self.healthStore startWorkoutSession:self.panicSession completion:^(BOOL success, NSError * __nullable error) {
        if (success)
        {
            NSDictionary *message = [BLNCommon messageUserInfoForType:BLNMessagePANICINTHEDISCOType payload:nil];
            [self.watchSession sendMessage:message replyHandler:^(NSDictionary<NSString *,id> * __nonnull replyMessage) {
                
            } errorHandler:^(NSError * __nonnull error) {
                
            }];
        }
        else
        {
            NSLog(@"Unable to start workout session: %@", error);
        }
    }];
}

- (void)panic
{
    NSDictionary *message = [BLNCommon messageUserInfoForType:BLNMessagePanicType payload:nil];
    [self.watchSession sendMessage:message replyHandler:^(NSDictionary<NSString *,id> * __nonnull replyMessage) {
        
    } errorHandler:^(NSError * __nonnull error) {
        
    }];
}

- (void)stopDefconState
{
    if (self.panicSession)
    {
        [self.healthStore stopWorkoutSession:self.panicSession completion:^(BOOL success, NSError * __nullable error) {
            
        }];
    }
    
    NSDictionary *message = [BLNCommon messageUserInfoForType:BLNMessageCheerioType payload:nil];
    [self.watchSession sendMessage:message replyHandler:^(NSDictionary<NSString *,id> * __nonnull replyMessage) {
        
    } errorHandler:^(NSError * __nonnull error) {
        
    }];
}

- (BLNAlertState)currentLocationScore
{
    return [[self.sortedIndexItems lastObject] alertState];
}

- (NSDate *)currentLocationScoreTimestamp
{
    return [[[self.sortedIndexItems lastObject] timestamp] copy];
}

- (void)requestLatestState
{
    if (self.watchSession.isReachable)
    {
        [self.watchSession sendMessage:[BLNCommon messageUserInfoForType:BLNMessageRequestLatestStateType payload:nil] replyHandler:^(NSDictionary<NSString *,id> * __nonnull replyMessage) {
            _BLNBallonIndexItem *indexItem = [[_BLNBallonIndexItem alloc] initWithBalloonMessageUserInfo:replyMessage];
            if (![[[self.sortedIndexItems lastObject] timestamp] isEqualToDate:indexItem.timestamp])
            {
                [(NSMutableSet *)self.ballonIndexItems addObject:indexItem];
                _sortedIndexItems = [self.ballonIndexItems sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES]]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    for (CLKComplication *complication in [[CLKComplicationServer sharedInstance] activeComplications])
                    {
                        if ([self.ballonIndexItems count] > 1)
                        {
                            [[CLKComplicationServer sharedInstance] extendTimelineForComplication:complication];
                        }
                        else
                        {
                            [[CLKComplicationServer sharedInstance] reloadTimelineForComplication:complication];
                        }
                    }
                });
            }
            
        } errorHandler:^(NSError * __nonnull error) {
            NSLog(@"Error getting latest state: %@", error);
        }];
    }
}

#pragma mark - WCSessionDelegate

- (void)session:(nonnull WCSession *)session didReceiveUserInfo:(nonnull NSDictionary<NSString *,id> *)userInfo
{
    if ([[BLNCommon typeForMessageUserInfo:userInfo] isEqualToString:BLNMessageUpdateComplicationType])
    {
        NSDictionary *data = [BLNCommon payloadForMessageUserInfo:userInfo];
        if (!data)
        {
            return;
        }
        [(NSMutableSet *)self.ballonIndexItems addObject:[[_BLNBallonIndexItem alloc] initWithBalloonMessageUserInfo:data]];
        _sortedIndexItems = [self.ballonIndexItems sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES]]];   
    }
}

@end
