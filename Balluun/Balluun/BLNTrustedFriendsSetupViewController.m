#import "BLNTrustedFriendsSetupViewController.h"
#import "BLNBalloonViewController.H"
#import "BLNManager.h"

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
    [[BLNManager sharedInstance] login];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
