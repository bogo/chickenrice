#import "BLNAlertState.h"
#import "UIColor+Balluun.h"

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

+ (UIColor *)colorFromAlertState:(BLNAlertState)alertState
{
    switch (alertState) {
        case BLNAlertStateGreen: {
            return [UIColor bln_greenColor];
        }
        case BLNAlertStateOrange: {
            return [UIColor bln_orangeColor];
        }
        case BLNAlertStateRed: {
            return [UIColor bln_redColor];
        }
        case BLNAlertStatePanicked:
        case BLNAlertStateDEFCON: {
            return [UIColor bln_defconColor];
        };
        default:
            return nil;
    }
}

@end
