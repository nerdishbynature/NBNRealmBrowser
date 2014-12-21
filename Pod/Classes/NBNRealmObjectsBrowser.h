@class RLMObjectSchema;
@class RLMRealm;
@class RLMResults;

@interface NBNRealmObjectsBrowser : UITableViewController

- (instancetype)initWithObjects:(RLMResults *)result;
- (instancetype)initWithObjectSchema:(RLMObjectSchema *)schema inRealm:(RLMRealm *)realm;

@end