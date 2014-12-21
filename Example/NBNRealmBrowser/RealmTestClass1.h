#import <Realm/Realm.h>
#import "RealmTestClass0.h"

@interface RealmTestClass1 : RLMObject

@property NSInteger integerValue;
@property BOOL boolValue;
@property float floatValue;
@property CGFloat doubleValue;
@property NSString *stringValue;
@property NSDate *dateValue;
@property RLMArray<RealmTestClass0> *arrayReference;

@end