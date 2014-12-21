@class RLMObjectSchema;
@class RLMRealm;

@interface NBNRealmObjectsBrowser : UITableViewController

- (instancetype)initWithObjectSchema:(RLMObjectSchema *)schema inRealm:(RLMRealm *)realm;

@end