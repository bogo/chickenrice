#import "BLNOwnerContactProvider.h"
#import "BLNContactHelper.h"

@implementation BLNOwnerContactProvider

- (CNContact *)provideContactToConfirm
{
    return [BLNContactHelper sharedHelper].deviceOwner;
}

@end
