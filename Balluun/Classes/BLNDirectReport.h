//
//  BLNDirectReport.h
//  Balluun
//
//  Created by Jeremy Foo on 11/7/15.
//  Copyright © 2015 Ottoman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchConnectivity/WatchConnectivity.h>
#import <ClockKit/ClockKit.h>
#import "BLNCommon.h"

@interface BLNDirectReport : NSObject <WCSessionDelegate, CLKComplicationDataSource>

@property (nonatomic, readonly, strong) WCSession *watchSession;
@property (nonatomic, readonly, strong) NSSet *ballonIndexItems;

@property (nonatomic, readonly, assign) BLNAlertState currentLocationScore;
@property (nonatomic, readonly, copy) NSDate *currentLocationScoreTimestamp;

+ (instancetype)sharedInstance;

- (void)requestLatestState;

@end
