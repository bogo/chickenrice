#import "BLNBalloonViewController.h"
#import "BLNManager.h"

@interface BLNBalloonViewController () <BLNManagerObserver>

@property (nonatomic, strong) UILabel *levelLabel;

@end

@implementation BLNBalloonViewController

- (instancetype)init
{
    if (!(self = [super init])) {
        return nil;
    }

    [[BLNManager sharedInstance] addObserver:self];

    return self;
}

- (void)dealloc
{
    [[BLNManager sharedInstance] removeObserver:self];
}

- (void)viewDidLoad
{
    self.levelLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.levelLabel];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSLog(@"Welcome to the balloon view!");
}

#pragma mark - BLNManagerObserver
- (void)manager:(BLNManager *)manager changedAlertStateTo:(BLNAlertState)alertState
{
    ;
}

@end
