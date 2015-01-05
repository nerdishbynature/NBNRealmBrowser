#import "NBNEmptyViewController.h"
#import "UIViewController+NBNNavigation.h"

@interface NBNEmptyViewController ()

@end

@implementation NBNEmptyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [self.splitViewController displayModeButtonItem];
    self.navigationItem.leftItemsSupplementBackButton = YES;
}

@end
