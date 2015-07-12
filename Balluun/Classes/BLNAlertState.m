#include "BLNAlertState.h"

@implementation BLNAlertStateHelper

+ (NSDictionary *)alertStateMappings
{
    return @{
        @(BLNAlertStateGreen) : @"Green",
        @(BLNAlertStateOrange) : @"Orange",
        @(BLNAlertStateRed) : @"Red",
        @(BLNAlertStateDEFCON) : @"DEFCON",
    };
}

+ (NSString *)stringFromAlertState:(BLNAlertState)alertState
{
    return [self alertStateMappings][@(alertState)];
}

@end
