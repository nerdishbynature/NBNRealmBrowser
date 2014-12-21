#import <UIKit/UIKit.h>

@class RLMRealm;

@interface NBNRealmBrowser : UITableViewController

- (instancetype)initWithRealm:(RLMRealm *)realm;

@end
