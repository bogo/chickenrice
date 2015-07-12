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

@end
