#import <Realm/Realm.h>

@class RealmTestClass1;

@interface RealmTestClass2 : RLMObject

@property NSInteger integerValue;
@property BOOL boolValue;
@property RealmTestClass1 *objectReference;

@end