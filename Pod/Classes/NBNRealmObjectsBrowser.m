#import "NBNRealmObjectsBrowser.h"
#import "NBNRealmObjectBrowser.h"

#define isIOS8 __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000

@interface NBNRealmObjectsBrowser ()
@property (nonatomic) RLMObjectSchema *schema;
@property (nonatomic) RLMRealm *realm;
@property (nonatomic) RLMResults *objects;
@property (nonatomic) NSArray *properties;
@property (nonatomic) NSArray *searchResults;
@end

#if isIOS8
@interface NBNRealmObjectsBrowser () <UISearchBarDelegate, UISearchResultsUpdating>
@property (nonatomic, strong) UISearchController *searchController;
@property BOOL searchControllerWasActive;
@property BOOL searchControllerSearchFieldWasFirstResponder;
@end
#endif

@implementation NBNRealmObjectsBrowser

- (instancetype)initWithObjects:(RLMResults *)result {
    self = [super initWithStyle:UITableViewStylePlain];

    if (self) {
        RLMObject *object = result.firstObject;
        _objects = result;
        _schema = object.objectSchema;
        _realm = result.realm;
        _properties = [_schema properties];
    }

    return self;
}

- (instancetype)initWithObjectSchema:(RLMObjectSchema *)schema inRealm:(RLMRealm *)realm {
    self = [super initWithStyle:UITableViewStylePlain];

    if (self) {
        _schema = schema;
        _realm = realm;
        _properties = [_schema properties];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.accessibilityIdentifier = NSStringFromClass(self.class);
    [self setupSearch];
}

- (void)setupSearch {
#if isIOS8
    UITableViewController *searchResultsController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    searchResultsController.tableView.dataSource = self;
    searchResultsController.tableView.delegate = self;
    _searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultsController];
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.placeholder = @"e.g. isDeveloper=1 AND name BEGINSWITH 'P'";
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.searchController.searchBar.delegate = self;
    self.definesPresentationContext = YES;
#endif
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    Class modelClass = NSClassFromString(self.schema.className);
    if (!self.objects) {
        self.objects = [(RLMObject *)modelClass performSelector:@selector(allObjectsInRealm:) withObject:self.realm];
        [self.tableView reloadData];
    }
    self.title = [NSString stringWithFormat:@"%u objects", self.objects.count];
#if isIOS8
    if (self.searchControllerWasActive) {
        self.searchController.active = self.searchControllerWasActive;
        _searchControllerWasActive = NO;

        if (self.searchControllerSearchFieldWasFirstResponder) {
            [self.searchController.searchBar becomeFirstResponder];
            _searchControllerSearchFieldWasFirstResponder = NO;
        }
    }
#endif
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#if isIOS8
    if (tableView == [(NBNRealmObjectsBrowser *)self.searchController.searchResultsController tableView]) {
        return self.searchResults.count;
    }
#endif
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellIdentifier"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    RLMObject *object = self.objects[(NSUInteger)indexPath.row];
#if isIOS8
    if (tableView == [(NBNRealmObjectsBrowser *)self.searchController.searchResultsController tableView]) {
        object = self.searchResults[(NSUInteger)indexPath.row];
    }
#endif

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
#if isIOS8
    if (tableView == [(NBNRealmObjectsBrowser *)self.searchController.searchResultsController tableView]) {
        object = self.searchResults[(NSUInteger)indexPath.row];
    }
#endif
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

#if isIOS8
#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    // update the filtered array based on the search text
    NSString *searchText = searchController.searchBar.text;
    NSString *strippedStr = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    if (strippedStr.length) {
        NSPredicate *predicate;
        @try {
            predicate = [NSPredicate predicateWithFormat:strippedStr];
        }
        @catch(NSException *exception) {
        }
        if (predicate) {
            Class objectClass = NSClassFromString(self.schema.className);
            @try {
                self.searchResults = [objectClass performSelector:@selector(objectsWithPredicate:) withObject:predicate];
            }
            @catch (NSException *exception) {
                NSLog(@"Caught %@", exception.name);
            }
            NBNRealmObjectsBrowser *realmBrowser= (NBNRealmObjectsBrowser *)self.searchController.searchResultsController;
            [realmBrowser.tableView reloadData];
        }
    }
}

#pragma mark - UIStateRestoration

static NSString *ViewControllerTitleKey = @"ViewControllerTitleKey";
static NSString *SearchControllerIsActiveKey = @"SearchControllerIsActiveKey";
static NSString *SearchBarTextKey = @"SearchBarTextKey";
static NSString *SearchBarIsFirstResponderKey = @"SearchBarIsFirstResponderKey";

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    [coder encodeObject:self.title forKey:ViewControllerTitleKey];
    UISearchController *searchController = self.searchController;
    BOOL searchDisplayControllerIsActive = searchController.isActive;
    [coder encodeBool:searchDisplayControllerIsActive forKey:SearchControllerIsActiveKey];
    if (searchDisplayControllerIsActive) {
        [coder encodeBool:[searchController.searchBar isFirstResponder] forKey:SearchBarIsFirstResponderKey];
    }
    [coder encodeObject:searchController.searchBar.text forKey:SearchBarTextKey];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    self.title = [coder decodeObjectForKey:ViewControllerTitleKey];
    _searchControllerWasActive = [coder decodeBoolForKey:SearchControllerIsActiveKey];
    _searchControllerSearchFieldWasFirstResponder = [coder decodeBoolForKey:SearchBarIsFirstResponderKey];
    self.searchController.searchBar.text = [coder decodeObjectForKey:SearchBarTextKey];
}
#endif

@end