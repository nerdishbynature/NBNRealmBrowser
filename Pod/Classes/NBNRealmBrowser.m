#import "NBNRealmBrowser.h"
#import "NBNRealmObjectsBrowser.h"
#import <Realm/Realm.h>

static NSString *CellIdentifier = @"CellIdentifier";

@interface NBNRealmBrowser ()
@property (nonatomic) RLMRealm *realm;
@property (nonatomic) NSArray *objectSchema;
@end

@implementation NBNRealmBrowser

- (instancetype)init {
    return [self initWithRealm:[RLMRealm defaultRealm]];
}

- (instancetype)initWithRealm:(RLMRealm *)realm {
    self = [super init];

    if (self) {
        _realm = realm;
        _objectSchema = _realm.schema.objectSchema;
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDismissButton];
}

#pragma mark - Setup

- (void)setupDismissButton {
    UIBarButtonItem *dismissItem = [[UIBarButtonItem alloc] initWithTitle:@"Dimiss" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss:)];
    self.navigationItem.leftBarButtonItem = dismissItem;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objectSchema.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    RLMObjectSchema *schema = self.objectSchema[(NSUInteger)indexPath.row];
    cell.textLabel.text = schema.className;
    Class modelClass = NSClassFromString(schema.className);
    RLMResults *objects = [(RLMObject *)modelClass performSelector:@selector(allObjectsInRealm:) withObject:self.realm];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%u objects", objects.count];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RLMObjectSchema *schema = self.objectSchema[(NSUInteger)indexPath.row];
    NBNRealmObjectsBrowser *objectsBrowser = [[NBNRealmObjectsBrowser alloc] initWithObjectSchema:schema
                                                                                          inRealm:self.realm];
    [self.navigationController pushViewController:objectsBrowser animated:YES];
}

#pragma mark - Button Actions

- (void)dismiss:(id)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
