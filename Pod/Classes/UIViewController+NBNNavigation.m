#import "UIViewController+NBNNavigation.h"
#import "NBNEmptyViewController.h"

@implementation UIViewController (NBNNavigation)

- (void)nbn_showViewController:(UIViewController *)viewController animated:(BOOL)animated {
#if isIOS8
    [self.splitViewController showViewController:viewController sender:self];
#else
    [self.navigationController pushViewController:viewController animated:animated];
#endif
}

- (void)nbn_showDetailViewController:(UIViewController *)viewController animated:(BOOL)animated {
#if isIOS8
    if (![viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
        [self.splitViewController showDetailViewController:navController sender:self];
    } else {
        [self.splitViewController showDetailViewController:viewController sender:self];
    }
#else
    [self.navigationController pushViewController:viewController animated:animated];
#endif
}

- (void)nbn_popViewControllerAnimated:(BOOL)animated {
#if isIOS8
    NBNEmptyViewController *emptyViewController = [[NBNEmptyViewController alloc] init];
    [self nbn_showDetailViewController:emptyViewController animated:NO];
#else
    [self.navigationController popViewControllerAnimated:animated];
#endif
}

@end
