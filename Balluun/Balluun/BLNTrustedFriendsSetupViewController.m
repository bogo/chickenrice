#import "BLNTrustedFriendsSetupViewController.h"
#import "BLNContactHelper.h"
@import Contacts;

@interface BLNTrustedFriendsSetupViewController ()

@property (nonatomic, strong) CNContact *ownerContact;

@end

@implementation BLNTrustedFriendsSetupViewController

- (instancetype)initWithOwnerContact:(CNContact *)ownerContact
{
    if (!(self = [super init])) {
        return nil;
    }
    
    _ownerContact = ownerContact;
    
    return self;
}

- (void)acceptContact
{
    NSLog(@"Your princess is in another castle!");
}

@end
