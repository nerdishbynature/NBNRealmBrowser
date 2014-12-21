#import "NBNRealmObjectsBrowser.h"
#import "NBNRealmObjectBrowser.h"

@interface NBNRealmObjectsBrowser ()
@property (nonatomic) RLMObjectSchema *schema;
@property (nonatomic) RLMRealm *realm;
@property (nonatomic) RLMResults *objects;
@property (nonatomic) NSArray *properties;
@end

@implementation NBNRealmObjectsBrowser

- (instancetype)initWithObjects:(RLMResults *)result {
    self = [super initWithStyle:UITableViewStylePlain];

    if (self) {
        RLMObject *object = result.firstObject;
        _objects = result;
        _schema = object.objectSchema;
        _realm = result.realm;
        _properties = [_schema properties];
        self.title = _schema.className;
    }

    return self;
}

- (instancetype)initWithObjectSchema:(RLMObjectSchema *)schema inRealm:(RLMRealm *)realm {
    self = [super initWithStyle:UITableViewStylePlain];

    if (self) {
        _schema = schema;
        _realm = realm;
        _properties = [_schema properties];
        self.title = _schema.className;
    }

    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    Class modelClass = NSClassFromString(self.schema.className);
    if (!self.objects) {
        self.objects = [(RLMObject *)modelClass performSelector:@selector(allObjectsInRealm:) withObject:self.realm];
        [self.tableView reloadData];
    }
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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RLMObject *object = self.objects[(NSUInteger)indexPath.row];
    NBNRealmObjectBrowser *objectBrowser = [[NBNRealmObjectBrowser alloc] initWithObject:object];
    [self.navigationController pushViewController:objectBrowser animated:YES];
}

#pragma mark - Helper

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