#import <UIKit/UIKit.h>
#import <Realm/Realm.h>

@protocol NBNRealmPropertyCellDelegate;

@interface NBNRealmPropertyCell : UITableViewCell

@property (nonatomic, weak) id<NBNRealmPropertyCellDelegate> delegate;

- (void)configureWithProperty:(RLMProperty *)aProperty
                     editMode:(BOOL)isEditing
                       object:(RLMObject *)object;

@end

@protocol NBNRealmPropertyCellDelegate <NSObject>
- (void)cellDidFinishEditing:(NBNRealmPropertyCell *)cell;
@end
