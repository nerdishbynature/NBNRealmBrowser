#import <UIKit/UIKit.h>

@class RLMRealm;

@interface NBNRealmBrowser : UITableViewController

+ (id)browserWithRealm:(RLMRealm *)realm;
+ (id)browser;

@end
