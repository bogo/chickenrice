#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, BLNAlertState) {
    BLNAlertStateGreen,
    BLNAlertStateOrange,
    BLNAlertStateRed,
    BLNAlertStateDEFCON
};

@interface BLNAlertStateHelper : NSObject

/**
 * Function returning an NSString for the BLNAlertState.
 */
+ (NSString *)stringFromAlertState:(BLNAlertState)alertState;

/**
 * Function returning a UIColor for the BLNAlertState.
 */
+ (UIColor *)colorFromAlertState:(BLNAlertState)alertState;

@end
