#import "NBNRealmObjectBrowser.h"
#import "NBNRealmObjectsBrowser.h"

@interface NBNRealmObjectBrowser ()
@property (nonatomic) RLMObject *object;
@property (nonatomic) RLMObjectSchema *schema;
@property (nonatomic) NSArray *properties;
@end

@implementation NBNRealmObjectBrowser

- (instancetype)initWithObject:(RLMObject *)object {
    self = [super initWithStyle:UITableViewStyleGrouped];

    if (self) {
        _object = object;
        _schema = _object.objectSchema;
        _properties = _schema.properties;
        self.title = _schema.className;
    }

    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.properties.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CellIdentifier"];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;

    RLMProperty *aProperty = self.properties[(NSUInteger)indexPath.row];
    cell.textLabel.text = aProperty.name;

    switch (aProperty.type) {
        case RLMPropertyTypeBool:
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            break;
        case RLMPropertyTypeObject:
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case RLMPropertyTypeArray: {
            RLMResults *value = [self.object objectForKeyedSubscript:aProperty.name];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%u objects", value.count];
        }
            break;
        default: {
            id value = [self.object objectForKeyedSubscript:aProperty.name];
            cell.detailTextLabel.text = [value description];
            break;
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RLMProperty *aProperty = self.properties[(NSUInteger)indexPath.row];
    switch (aProperty.type) {
        case RLMPropertyTypeObject: {
            RLMObject *object = [self.object objectForKeyedSubscript:aProperty.name];
            NBNRealmObjectBrowser *objectBrowser = [[NBNRealmObjectBrowser alloc] initWithObject:object];
            [self.navigationController pushViewController:objectBrowser animated:YES];
        }
            break;
        case RLMPropertyTypeArray: {
            RLMResults *value = [self.object objectForKeyedSubscript:aProperty.name];
            NBNRealmObjectsBrowser *objectsBrowser = [[NBNRealmObjectsBrowser alloc] initWithObjects:value];
            [self.navigationController pushViewController:objectsBrowser animated:YES];
        }
            break;
        default:
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            break;
    }
}

@end