#import "UIViewController+NBNNavigation.h"

@implementation UIViewController (NBNNavigation)

- (void)nbn_popViewControllerAnimated:(BOOL)animated {
    UIViewController *viewController = [[UIViewController alloc] init];
    [self.detailNavigationController setViewControllers:@[viewController] animated:NO];
}

- (UINavigationController *)detailNavigationController {
#ifdef isIOS8
    static UINavigationController *detailNavigationController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        detailNavigationController = [[UINavigationController alloc] init];
    });
    return detailNavigationController;
#else
    return self.navigationController;
#endif
}

- (UINavigationController *)masterNavigationController {
#ifdef isIOS8
    static UINavigationController *masterNavigationController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        masterNavigationController = [[UINavigationController alloc] init];
    });
    return masterNavigationController;
#else
    return self.navigationController;
#endif
}

@end
