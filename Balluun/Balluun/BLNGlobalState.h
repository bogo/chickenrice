#import <Foundation/Foundation.h>

/**
 * Enum to describe the login states.
 */
typedef NS_ENUM(NSUInteger, BLNGlobalLoginState) {
    BLNGlobalLoginStateLoggedOut,
    BLNGlobalLoginStateLoggedIn,
};

/**
 * A class to provide access to Balluun states. Should be accessed via the
 * +sharedState singleton.
 */
@interface BLNGlobalState : NSObject

/**
 * Current login state.
 */
@property (nonatomic, assign, readonly) BLNGlobalLoginState loginState;

/**
 * Provides access to global state throughout the application.
 */
+ (instancetype)sharedState;

@end
