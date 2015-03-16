#import "NBNRealmPropertyCell.h"
#import <Realm/Realm.h>

@interface NBNRealmPropertyCell () <UITextFieldDelegate>
@property (nonatomic) RLMProperty *property;
@property (nonatomic) RLMObject *object;
@property (nonatomic) UITextField *textField;
@property (nonatomic, assign) BOOL isEditing;
@end

@implementation NBNRealmPropertyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self) {
        _textField = [[UITextField alloc] initWithFrame:CGRectZero];
        _textField.backgroundColor = [UIColor redColor];
        _textField.textColor = [UIColor whiteColor];
        _textField.delegate = self;
        _textField.returnKeyType = UIReturnKeyDone;
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.textField.frame = self.detailTextLabel.frame;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (self.property.type == RLMPropertyTypeBool && self.isEditing && selected) {
        NSNumber *value = [self.object objectForKeyedSubscript:self.property.name];
        value = @(![value boolValue]);
        [self.object.realm beginWriteTransaction];
        [self.object setObject:value forKeyedSubscript:self.property.name];
        [self.object.realm commitWriteTransaction];
        if ([self.delegate respondsToSelector:@selector(cellDidFinishEditing:)]) {
            [self.delegate cellDidFinishEditing:self];
        }
    }
}

- (void)configureWithProperty:(RLMProperty *)aProperty
                     editMode:(BOOL)isEditing
                       object:(RLMObject *)object {
    self.isEditing = isEditing;
    self.property = aProperty;
    self.object = object;
    self.accessoryType = UITableViewCellAccessoryNone;
    self.textLabel.text = aProperty.name;
    [self.textField removeFromSuperview];


    switch (aProperty.type) {
        case RLMPropertyTypeBool: {
            NSNumber *value = [object objectForKeyedSubscript:aProperty.name];
            self.accessoryType = [value boolValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        }
            break;
        case RLMPropertyTypeObject: {
            self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } break;
        case RLMPropertyTypeArray: {
            RLMResults *value = [object objectForKeyedSubscript:aProperty.name];
            self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            self.detailTextLabel.text = [NSString stringWithFormat:@"%lu objects", (unsigned long)value.count];
        } break;
        case RLMPropertyTypeString:
        case RLMPropertyTypeDouble:
        case RLMPropertyTypeFloat:
        case RLMPropertyTypeInt: {
            id value = [object objectForKeyedSubscript:aProperty.name];
            if (isEditing) {
                [self setTextFieldText:[value description]];
            } else {
                self.detailTextLabel.text = [value description];
            }
        } break;
        default: {
            id value = [object objectForKeyedSubscript:aProperty.name];
            self.detailTextLabel.text = [value description];
        } break;
    }
}

- (void)setTextFieldText:(id)value {
    [self.contentView addSubview:self.textField];
    self.textField.text = [value description];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self.object.realm beginWriteTransaction];
    switch (self.property.type) {
        case RLMPropertyTypeInt: {
            NSInteger value = [textField.text integerValue];
            if (value) {
                [self.object setObject:@(value) forKeyedSubscript:self.property.name];
            }
        } break;
        case RLMPropertyTypeDouble: {
            CGFloat value = [textField.text doubleValue];
            if (value) {
                [self.object setObject:@(value) forKeyedSubscript:self.property.name];
            }
        } break;
        case RLMPropertyTypeFloat: {
            CGFloat value = [textField.text doubleValue];
            if (value) {
                [self.object setObject:@(value) forKeyedSubscript:self.property.name];
            }
        } break;
        case RLMPropertyTypeString: {
            [self.object setObject:textField.text forKeyedSubscript:self.property.name];
        }
        default: break;
    }

    [self.object.realm commitWriteTransaction];
    if ([self.delegate respondsToSelector:@selector(cellDidFinishEditing:)]) {
        [self.delegate cellDidFinishEditing:self];
    }

    return NO;
}

@end
