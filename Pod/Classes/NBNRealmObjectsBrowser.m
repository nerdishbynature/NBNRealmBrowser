#import "NBNRealmObjectsBrowser.h"
#import <Realm/Realm.h>

@interface NBNRealmObjectsBrowser ()
@property (nonatomic) RLMObjectSchema *schema;
@property (nonatomic) RLMRealm *realm;
@property (nonatomic) RLMResults *objects;
@property (nonatomic) NSArray *properties;
@end

@implementation NBNRealmObjectsBrowser

- (instancetype)initWithObjectSchema:(RLMObjectSchema *)schema inRealm:(RLMRealm *)realm {
    self = [super initWithStyle:UITableViewStyleGrouped];

    if (self) {
        _schema = schema;
        _realm = realm;
    }

    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.title = self.schema.className;
    Class modelClass = NSClassFromString(self.schema.className);
    self.properties = [self.schema properties];
    self.objects = [(RLMObject *)modelClass performSelector:@selector(allObjectsInRealm:) withObject:self.realm];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellIdentifier"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    RLMObject *object = self.objects[(NSUInteger)indexPath.row];

    NSMutableArray *propertyValues = [NSMutableArray arrayWithCapacity:self.properties.count];
    for (RLMProperty *aProperty in self.properties) {
        NSString *stringValue = [self stringForProperty:aProperty inObject:object];
        if (stringValue) {
            [propertyValues addObject:[@[aProperty.name, stringValue] componentsJoinedByString:@" = "]];
        }
    }

    NSString *title = self.schema.className;
    if (self.schema.primaryKeyProperty) {
        title = [self stringForProperty:self.schema.primaryKeyProperty inObject:object];
    }
    cell.textLabel.text = title;
    cell.detailTextLabel.text = [propertyValues componentsJoinedByString:@", "];

    return cell;
}

- (NSString *)stringForProperty:(RLMProperty *)aProperty inObject:(RLMObject *)object {
    NSString *stringValue;
    switch (aProperty.type) {
        case RLMPropertyTypeInt:
        case RLMPropertyTypeFloat:
        case RLMPropertyTypeBool:
        case RLMPropertyTypeDouble:
            stringValue = [(NSNumber *)[object objectForKeyedSubscript:aProperty.name] stringValue];
            break;
        case RLMPropertyTypeString:
            stringValue = (NSString *)[object objectForKeyedSubscript:aProperty.name];
            break;
        case RLMPropertyTypeData:
        case RLMPropertyTypeAny:
        case RLMPropertyTypeDate:
        case RLMPropertyTypeObject:
        case RLMPropertyTypeArray:
            stringValue = [(NSData *)[object objectForKeyedSubscript:aProperty.name] description];
            break;
    }
    return stringValue;
}

@end