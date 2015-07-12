#import <Foundation/Foundation.h>
@class CNContact;

@protocol BLNContactProvider <NSObject>

- (CNContact *)provideContactToConfirm;

@end
