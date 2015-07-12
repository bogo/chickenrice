#import "BLNGlobalState.h"

@interface BLNGlobalState ()

@property (nonatomic, assign, readwrite) BLNGlobalLoginState loginState;

@end

@implementation BLNGlobalState

+ (instancetype)sharedState
{
    static BLNGlobalState *globalState = nil;
    if (!globalState) {
        globalState = [BLNGlobalState new];
    }
    return globalState;
}

- (instancetype)init
{
    if (!(self = [super init])) {
        return nil;
    }
    
    [self setupLoginState];
    
    return self;
}

- (void)setupLoginState
{
    _loginState = BLNGlobalLoginStateLoggedOut;
}

@end
