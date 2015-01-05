#import <UIKit/UIKit.h>

#define isIOS8 __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000

@interface UIViewController (NBNNavigation)

- (UINavigationController *)detailNavigationController;
- (UINavigationController *)masterNavigationController;
- (void)nbn_popViewControllerAnimated:(BOOL)animated;

@end
