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

@interface BLNDirectReport ()

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
        
        _ballonIndexItems = [NSMutableSet setWithCapacity:0];
    }
    return self;
}

#pragma mark - State

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
