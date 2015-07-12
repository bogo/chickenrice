//
//  BLNDirectReport.m
//  Balluun
//
//  Created by Jeremy Foo on 11/7/15.
//  Copyright © 2015 Ottoman. All rights reserved.
//

#import "BLNDirectReport.h"

@interface _BLNBallonIndexItem : NSObject
@property (nonatomic, assign, readonly) BLNAlertState alertState;
@property (nonatomic, strong, readonly) NSDate *timestamp;
- (instancetype)initWithBalloonMessageUserInfo:(NSDictionary *)ballonUserInfo;
@end

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
@property (nonatomic, copy) NSArray *sortedIndexItems;

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
            NSDictionary *data = [BLNCommon payloadForMessageUserInfo:replyMessage];
            if (!data)
            {
                return;
            }
            _BLNBallonIndexItem *indexItem = [[_BLNBallonIndexItem alloc] initWithBalloonMessageUserInfo:data];
            if (![[[self.sortedIndexItems lastObject] timestamp] isEqualToDate:indexItem.timestamp])
            {
                [(NSMutableSet *)self.ballonIndexItems addObject:indexItem];
                _sortedIndexItems = [self.ballonIndexItems sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES]]];
                
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

#pragma mark - Timeline Configuration

- (void)getSupportedTimeTravelDirectionsForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimeTravelDirections directions))handler
{
    handler(CLKComplicationTimeTravelDirectionBackward);
}

- (void)getTimelineStartDateForComplication:(CLKComplication *)complication withHandler:(void(^)(__nullable NSDate *date))handler
{
    handler([self.sortedIndexItems firstObject]);
}

- (void)getTimelineEndDateForComplication:(CLKComplication *)complication withHandler:(void(^)(__nullable NSDate *date))handler
{
    handler([self.sortedIndexItems lastObject]);
}

- (void)getPrivacyBehaviorForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationPrivacyBehavior privacyBehavior))handler
{
    handler(CLKComplicationPrivacyBehaviorShowOnLockScreen);
}

#pragma mark - Timeline Population

- (void)getCurrentTimelineEntryForComplication:(CLKComplication *)complication withHandler:(void(^)(__nullable CLKComplicationTimelineEntry *))handler
{
    // Call the handler with the current timeline entry
    _BLNBallonIndexItem *currentIndexItem = [self.sortedIndexItems lastObject];
    handler(TimeLineEntry(complication, currentIndexItem));
}

- (void)getTimelineEntriesForComplication:(CLKComplication *)complication beforeDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void(^)(__nullable NSArray<CLKComplicationTimelineEntry *> *entries))handler
{
    _BLNBallonIndexItem *currentIndexItem = [self.sortedIndexItems lastObject];
    NSArray *indexItems = [self.sortedIndexItems filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"timestamp < %@ AND SELF != %@", date, currentIndexItem]];
    NSArray *prunedItems = [indexItems subarrayWithRange:NSMakeRange(0, MIN(limit, [indexItems count]))];
    
    NSMutableArray *finalEntries = [NSMutableArray arrayWithCapacity:[prunedItems count]];
    for (_BLNBallonIndexItem *item in prunedItems)
    {
        CLKComplicationTimelineEntry *entry = TimeLineEntry(complication, item);
        [finalEntries addObject:entry];
    }
    
    handler(finalEntries);
}

- (void)getTimelineEntriesForComplication:(CLKComplication *)complication afterDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void(^)(__nullable NSArray<CLKComplicationTimelineEntry *> *entries))handler
{
    _BLNBallonIndexItem *currentIndexItem = [self.sortedIndexItems lastObject];
    NSArray *indexItems = [self.sortedIndexItems filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"timestamp > %@ AND SELF != %@", date, currentIndexItem]];
    if ([indexItems count] == 0)
    {
        handler(nil);
        return;
    }
    NSUInteger length = MIN(limit, [indexItems count]);
    NSArray *prunedItems = [indexItems subarrayWithRange:NSMakeRange([indexItems count] - length, length)];
    
    NSMutableArray *finalEntries = [NSMutableArray arrayWithCapacity:[prunedItems count]];
    for (_BLNBallonIndexItem *item in prunedItems)
    {
        CLKComplicationTimelineEntry *entry = TimeLineEntry(complication, item);
        [finalEntries addObject:entry];
    }

    handler(finalEntries);
}

#pragma mark Update Scheduling

- (void)getNextRequestedUpdateDateWithHandler:(void(^)(__nullable NSDate *updateDate))handler
{
    // Call the handler with the date when you would next like to be given the opportunity to update your complication content
    handler([[NSDate date] dateByAddingTimeInterval:(3 * 60)]);
}

#pragma mark - Placeholder Templates

- (void)getPlaceholderTemplateForComplication:(CLKComplication *)complication withHandler:(void(^)(__nullable CLKComplicationTemplate *complicationTemplate))handler
{
    handler(ComplicationTemplate(complication, nil));
}

static CLKComplicationTimelineEntry* TimeLineEntry(CLKComplication *complication, _BLNBallonIndexItem *indexItem)
{
    CLKComplicationTemplate *template = ComplicationTemplate(complication, indexItem);
    return [CLKComplicationTimelineEntry entryWithDate:indexItem.timestamp complicationTemplate:template];
}

static CLKComplicationTemplate* ComplicationTemplate(CLKComplication *complication, _BLNBallonIndexItem *indexItem)
{
    NSString *text = @":(";
    float fillFraction = 0.0;
    if (indexItem)
    {
        text = [NSString stringWithFormat:@"%i", indexItem.alertState];
        fillFraction = (float)indexItem.alertState / (float)BLNAlertStateDEFCON;
    }
    
    CLKComplicationTemplate *template = nil;
    
    // This method will be called once per supported complication, and the results will be cached
    switch (complication.family) {
        case CLKComplicationFamilyModularSmall:
            template = [CLKComplicationTemplateModularSmallRingText new];
            [(CLKComplicationTemplateModularSmallRingText *)template setRingStyle:CLKComplicationRingStyleClosed];
            [(CLKComplicationTemplateModularSmallRingText *)template setFillFraction:fillFraction];
            [(CLKComplicationTemplateModularSmallRingText *)template setTextProvider:[CLKSimpleTextProvider textProviderWithText:text]];
            break;
        case CLKComplicationFamilyCircularSmall:
            template = [CLKComplicationTemplateCircularSmallRingText new];
            [(CLKComplicationTemplateCircularSmallRingText *)template setRingStyle:CLKComplicationRingStyleClosed];
            [(CLKComplicationTemplateCircularSmallRingText *)template setFillFraction:fillFraction];
            [(CLKComplicationTemplateCircularSmallRingText *)template setTextProvider:[CLKSimpleTextProvider textProviderWithText:text]];
            break;
        case CLKComplicationFamilyUtilitarianSmall:
            template = [CLKComplicationTemplateUtilitarianSmallRingText new];
            [(CLKComplicationTemplateUtilitarianSmallRingText *)template setRingStyle:CLKComplicationRingStyleClosed];
            [(CLKComplicationTemplateUtilitarianSmallRingText *)template setFillFraction:fillFraction];
            [(CLKComplicationTemplateUtilitarianSmallRingText *)template setTextProvider:[CLKSimpleTextProvider textProviderWithText:text]];
            break;
        default:
            break;
    }

    return template;
}

@end
