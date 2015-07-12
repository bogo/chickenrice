#import "BLNAppDelegate.h"
#import "BLNManager.h"
#import "BLNMetaViewController.h"
#import "BLNLaunchViewController.h"
@import CoreLocation;

@interface BLNAppDelegate ()

@end

@implementation BLNAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[BLNManager sharedInstance] updateWatch];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    self.window.rootViewController = [[BLNMetaViewController alloc] initWithRootViewController:[BLNLaunchViewController new]];

    [[BLNManager sharedInstance] requestPermissions];

    UIMutableUserNotificationAction *okayAction = [[UIMutableUserNotificationAction alloc] init];
    okayAction.activationMode = UIUserNotificationActivationModeBackground;
    okayAction.identifier = @"amokay";
    okayAction.title = @"I'm okay";
    okayAction.authenticationRequired = NO;
    
    UIMutableUserNotificationAction *noOkayAction = [[UIMutableUserNotificationAction alloc] init];
    noOkayAction.activationMode = UIUserNotificationActivationModeBackground;
    noOkayAction.identifier = @"notokay";
    noOkayAction.title = @"Not Okay";
    noOkayAction.destructive = YES;
    noOkayAction.authenticationRequired = NO;
    
    UIMutableUserNotificationCategory *reassuranceCategory = [[UIMutableUserNotificationCategory alloc] init];
    [reassuranceCategory setActions:@[okayAction, noOkayAction] forContext:UIUserNotificationActionContextDefault];
    reassuranceCategory.identifier = @"reassurance";

    UIUserNotificationType types = UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:[NSMutableSet setWithObject:reassuranceCategory]];
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    ;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    ;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    ;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    ;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    ;
}

- (void)applicationShouldRequestHealthAuthorization:(nonnull UIApplication *)application
{
    [[BLNManager sharedInstance] requestPermissions];
}

- (void)application:(nonnull UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forLocalNotification:(nonnull UILocalNotification *)notification completionHandler:(nonnull void (^)())completionHandler
{
    if ([identifier isEqualToString:@"notokay"])
    {
        [[BLNManager sharedInstance] panic];
    }
    completionHandler();
}


@end
