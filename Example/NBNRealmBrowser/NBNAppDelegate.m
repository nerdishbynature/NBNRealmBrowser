#import "NBNAppDelegate.h"
#import "NBNViewController.h"
#import "RLMRealm.h"

@implementation NBNAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

    NBNViewController *viewController = [[NBNViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    self.window.rootViewController = navController;

    [self copyDataBaseIfNeeded];
    [RLMRealm defaultRealm];

    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)copyDataBaseIfNeeded {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dbPath = [self dbPath];
    if (![fileManager fileExistsAtPath:dbPath]) {
        NSString *bundleDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"default.realm"];
        [fileManager copyItemAtPath:bundleDBPath toPath:dbPath error:nil];
    }
}

- (NSString *)dbPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths.firstObject;
    return [documentsDirectory stringByAppendingPathComponent:@"default.realm"];
}

@end
