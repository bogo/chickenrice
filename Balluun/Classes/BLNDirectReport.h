//
//  BLNDirectReport.h
//  Balluun
//
//  Created by Jeremy Foo on 11/7/15.
//  Copyright © 2015 Ottoman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchConnectivity/WatchConnectivity.h>
#import "BLNCommon.h"

@interface BLNDirectReport : NSObject <WCSessionDelegate>

@property (nonatomic, readonly, strong) WCSession *watchSession;
@property (nonatomic, readonly, strong) NSSet *ballonIndexItems;
@property (nonatomic, readonly, copy) NSArray *sortedIndexItems;

@property (nonatomic, readonly, assign) BLNAlertState currentLocationScore;
@property (nonatomic, readonly, copy) NSDate *currentLocationScoreTimestamp;

+ (instancetype)sharedInstance;

- (void)requestLatestState;
- (void)startDefconState;
- (void)stopDefconState;

@end

@interface _BLNBallonIndexItem : NSObject
@property (nonatomic, assign, readonly) BLNAlertState alertState;
@property (nonatomic, strong, readonly) NSDate *timestamp;
- (instancetype)initWithBalloonMessageUserInfo:(NSDictionary *)ballonUserInfo;
@end