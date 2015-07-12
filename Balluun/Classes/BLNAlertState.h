#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, BLNAlertState) {
    BLNAlertStateGreen,
    BLNAlertStateOrange,
    BLNAlertStateRed,
    BLNAlertStateDEFCON
};

@interface BLNAlertStateHelper : NSObject

/**
 *  Function returning an NSString for the BLNAlertState.
 */
+ (NSString *)stringFromAlertState:(BLNAlertState)alertState;

@end
