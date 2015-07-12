#import "BLNContactHelper.h"
@import Contacts;
@import ContactsUI.CNContactViewController;

@interface BLNContactHelper ()

@property (nonatomic, strong) CNContactStore *contactStore;
@property (nonatomic, assign, readwrite) BOOL authorized;

@end

@implementation BLNContactHelper

+ (instancetype)sharedHelper
{
    static BLNContactHelper *sharedHelper = nil;
    if (!sharedHelper) {
        sharedHelper = [BLNContactHelper new];
    }
    return sharedHelper;
}

- (instancetype)init
{
    if (!(self = [super init])) {
        return nil;
    }
    
    _contactStore = [CNContactStore new];

    return self;
}

- (void)authorize
{
    __weak typeof(self) weakSelf = self;
    [self.contactStore requestAccessForEntityType:CNEntityTypeContacts
                                completionHandler:^(BOOL granted, NSError * __nullable error) {
                                    weakSelf.authorized = granted;
                                }];
}

- (CNContact *)deviceOwner
{
    NSPredicate *predicate = [CNContact predicateForContactsMatchingName:@"Rybka"];
    
    NSError *error = nil;
    NSArray *contacts = [self.contactStore unifiedContactsMatchingPredicate:predicate
                                                                keysToFetch:[BLNContactHelper keysToFetch]
                                                                      error:&error];
    CNContact *owner = contacts[0];
    return owner;
}

- (CNContact *)ownersPartner
{
    CNContactRelation *relation = self.deviceOwner.contactRelations[0].value;
    NSPredicate *predicate = [CNContact predicateForContactsMatchingName:relation.name];

    NSError *error = nil;
    NSArray *contacts = [self.contactStore unifiedContactsMatchingPredicate:predicate
                                                                keysToFetch:[BLNContactHelper keysToFetch]
                                                                      error:&error];
    
    CNContact *partner = contacts[0];
    return partner;
}

+ (NSArray *)keysToFetch
{
    NSArray *keysToFetch = @[
                             [CNContactViewController descriptorForRequiredKeys],
                             ];
    return keysToFetch;
}

@end
