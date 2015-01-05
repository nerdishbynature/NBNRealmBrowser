#import "NBNRealmBrowser.h"
#import "NBNRealmObjectsBrowser.h"
#import "NBNEmptyViewController.h"
#include "UIViewController+NBNNavigation.h"
#import <Realm/Realm.h>

#define isIOS8 __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000

static NSString *CellIdentifier = @"CellIdentifier";

@interface NBNRealmBrowser ()
@property (nonatomic) RLMRealm *realm;
@property (nonatomic) NSArray *objectSchema;
@property (nonatomic) NSArray *searchResults;
@end

#if isIOS8
@interface NBNRealmBrowser () <UISearchBarDelegate, UISearchResultsUpdating>
@property (nonatomic, strong) UISearchController *searchController;
@property BOOL searchControllerWasActive;
@property BOOL searchControllerSearchFieldWasFirstResponder;
@end
#endif

@implementation NBNRealmBrowser

+ (id)browserWithRealm:(RLMRealm *)realm {
    NBNRealmBrowser *realmBrowser = [[NBNRealmBrowser alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:realmBrowser];
#if isIOS8
    UISplitViewController *splitViewController = [[UISplitViewController alloc] init];
    splitViewController.modalPresentationStyle = UIModalTransitionStyleCoverVertical;
    splitViewController.viewControllers = @[navController];
    return splitViewController;
#else
    return navController;
#endif
}

+ (id)browser {
    return [self browserWithRealm:[RLMRealm defaultRealm]];
}

- (instancetype)init {
    return [self initWithRealm:[RLMRealm defaultRealm]];
}

- (instancetype)initWithRealm:(RLMRealm *)realm {
    self = [super init];

    if (self) {
        _realm = realm;
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"className" ascending:YES];
        _objectSchema = [_realm.schema.objectSchema sortedArrayUsingDescriptors:@[sort]];
        self.title = @"Classes";
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDismissButton];
    [self setupSearch];
    NBNEmptyViewController *emptyViewController = [[NBNEmptyViewController alloc] init];
    UINavigationController *detailNavController = [[UINavigationController alloc] initWithRootViewController:emptyViewController];
    [self nbn_showDetailViewController:detailNavController animated:NO];
}

- (void)setupSearch {
#if isIOS8
    UITableViewController *searchResultsController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    searchResultsController.tableView.dataSource = self;
    searchResultsController.tableView.delegate = self;
    _searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultsController];
    self.searchController.searchResultsUpdater = self;
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.searchController.searchBar.delegate = self;
    self.definesPresentationContext = YES;
#endif
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData];
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

#pragma mark - Setup

- (void)setupDismissButton {
    UIBarButtonItem *dismissItem = [[UIBarButtonItem alloc] initWithTitle:@"Dismiss" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss:)];
    self.navigationItem.leftBarButtonItem = dismissItem;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#if isIOS8
    if (tableView == [(NBNRealmBrowser *)self.searchController.searchResultsController tableView]) {
        return self.searchResults.count;
    }
#endif
    return self.objectSchema.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    RLMObjectSchema *schema = self.objectSchema[(NSUInteger)indexPath.row];
#if isIOS8
    if (tableView == [(NBNRealmBrowser *)self.searchController.searchResultsController tableView]) {
        schema = self.searchResults[(NSUInteger)indexPath.row];
    }
#endif
    cell.textLabel.text = schema.className;
    Class modelClass = NSClassFromString(schema.className);
    RLMResults *objects = [(RLMObject *)modelClass performSelector:@selector(allObjectsInRealm:) withObject:self.realm];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu objects", (unsigned long)objects.count];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RLMObjectSchema *schema = self.objectSchema[(NSUInteger)indexPath.row];
#if isIOS8
    if (tableView == [(NBNRealmBrowser *)self.searchController.searchResultsController tableView]) {
        schema = self.searchResults[(NSUInteger)indexPath.row];
    }
#endif
    NBNRealmObjectsBrowser *objectsBrowser = [[NBNRealmObjectsBrowser alloc] initWithObjectSchema:schema
                                                                                          inRealm:self.realm];
    [self.navigationController pushViewController:objectsBrowser animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Button Actions

- (void)dismiss:(id)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
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
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(RLMObjectSchema * evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject.className containsString:strippedStr];
        }];
        self.searchResults = [self.objectSchema filteredArrayUsingPredicate:predicate];
        NBNRealmBrowser *realmBrowser= (NBNRealmBrowser *)self.searchController.searchResultsController;
        [realmBrowser.tableView reloadData];
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
