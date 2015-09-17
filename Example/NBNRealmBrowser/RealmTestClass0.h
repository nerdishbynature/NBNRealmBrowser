#import <Realm/RLMObject.h>
#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

@interface RealmTestClass0 : RLMObject

@property NSInteger integerValue;
@property NSString *stringValue;
@property NSData *dataValue;

@end

RLM_ARRAY_TYPE(RealmTestClass0);