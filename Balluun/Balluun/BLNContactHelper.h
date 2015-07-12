#import <Foundation/Foundation.h>
@class CNContact;

@interface BLNContactHelper : NSObject

@property (nonatomic, assign, readonly) BOOL authorized;
@property (nonatomic, strong, readonly) CNContact *deviceOwner;

+ (instancetype)sharedHelper;

- (CNContact *)ownersPartner;

- (void)authorize;

@end
