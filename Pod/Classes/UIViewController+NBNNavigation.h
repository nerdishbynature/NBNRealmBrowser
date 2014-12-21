#import <UIKit/UIKit.h>

#define isIOS8 __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000

@interface UIViewController (NBNNavigation)

- (void)nbn_showViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)nbn_showDetailViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)nbn_popViewControllerAnimated:(BOOL)animated;

@end
