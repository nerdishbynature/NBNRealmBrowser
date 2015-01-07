#import "NBNRealmObjectBrowser.h"
#import "NBNRealmObjectsBrowser.h"
#import "UIViewController+NBNNavigation.h"
#import "NBNRealmPropertyCell.h"

typedef NS_ENUM(NSUInteger, NBNRealmObjectBrowserSection) {
    NBNRealmObjectBrowserSectionProperties,
    NBNRealmObjectBrowserSectionDelete
};

@interface NBNRealmObjectBrowser () <NBNRealmPropertyCellDelegate>
@property (nonatomic) RLMObject *object;
@property (nonatomic) RLMObjectSchema *schema;
@property (nonatomic) NSArray *properties;
@property (nonatomic, assign) BOOL editingModeEnabled;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [self.splitViewController displayModeButtonItem];
    self.navigationItem.leftItemsSupplementBackButton = YES;
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(toggleEditing:)];
    self.navigationItem.rightBarButtonItem = editButton;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == NBNRealmObjectBrowserSectionProperties) {
        return self.properties.count;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == NBNRealmObjectBrowserSectionProperties) {
        NBNRealmPropertyCell *cell = (NBNRealmPropertyCell *)[tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];

        if (!cell) {
            cell = [[NBNRealmPropertyCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CellIdentifier"];
            cell.delegate = self;
        }

        RLMProperty *aProperty = self.properties[(NSUInteger)indexPath.row];
        [cell configureWithProperty:aProperty editMode:self.editingModeEnabled object:self.object];

        return cell;
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeleteCellIdentifier"];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DeleteCellIdentifier"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    cell.textLabel.text = @"Delete Entity";
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.contentView.backgroundColor = [UIColor redColor];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == NBNRealmObjectBrowserSectionProperties) {
        RLMProperty *aProperty = self.properties[(NSUInteger) indexPath.row];
        switch (aProperty.type) {
            case RLMPropertyTypeObject: {
                RLMObject *object = [self.object objectForKeyedSubscript:aProperty.name];
                NBNRealmObjectBrowser *objectBrowser = [[NBNRealmObjectBrowser alloc] initWithObject:object];
                [self.detailNavigationController pushViewController:objectBrowser animated:YES];
            }
                break;
            case RLMPropertyTypeArray: {
                RLMResults *value = [self.object objectForKeyedSubscript:aProperty.name];
                NBNRealmObjectsBrowser *objectsBrowser = [[NBNRealmObjectsBrowser alloc] initWithObjects:value];
                [self.detailNavigationController pushViewController:objectsBrowser animated:YES];
            }
                break;
            default:
                [tableView deselectRowAtIndexPath:indexPath animated:NO];
                break;
        }
    } else if (indexPath.section == NBNRealmObjectBrowserSectionDelete) {
        [self.object.realm transactionWithBlock:^{
            [self.object.realm deleteObject:self.object];
        }];
        [self nbn_popViewControllerAnimated:YES];
    }
}

#pragma mark - Editing

- (void)toggleEditing:(UIBarButtonItem *)sender {
    self.editingModeEnabled = !self.editingModeEnabled;
    sender.title = self.editingModeEnabled ? @"Done" : @"Edit";
    [self.tableView reloadData];
}

- (void)cellDidFinishEditing:(NBNRealmPropertyCell *)cell {
    [self toggleEditing:self.navigationItem.rightBarButtonItem];
}

@end