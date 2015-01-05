#import "NBNViewController.h"
#import <NBNRealmBrowser/NBNRealmBrowser.h>

@interface NBNViewController ()

@end

@implementation NBNViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupRealmBrowserButton];
}

- (void)setupRealmBrowserButton {
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Realm Browser"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(openRealmBrowser:)];
    self.navigationItem.rightBarButtonItem = barButtonItem;
}

- (void)openRealmBrowser:(id)sender {
    [self presentViewController:[NBNRealmBrowser browser] animated:YES completion:nil];
}

@end
