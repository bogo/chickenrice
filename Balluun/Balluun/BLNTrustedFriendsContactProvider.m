#import "BLNTrustedFriendsContactProvider.h"
#import "BLNContactHelper.h"

@implementation BLNTrustedFriendsContactProvider

- (CNContact *)provideContactToConfirm
{
    return [BLNContactHelper sharedHelper].ownersPartner;
}

@end
