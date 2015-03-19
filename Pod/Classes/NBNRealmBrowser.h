#import <UIKit/UIKit.h>

@class RLMRealm;

@interface NBNRealmBrowser : UITableViewController

+ (id)browserWithRealmAtPath:(NSString *)realmPath;
+ (id)browserWithRealm:(RLMRealm *)realm;
+ (id)browser;

@end
