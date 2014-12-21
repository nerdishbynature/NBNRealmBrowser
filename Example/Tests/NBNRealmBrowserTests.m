#import <KIF/KIF.h>

@interface NBNRealmBrowserTests : KIFTestCase

@end

@implementation NBNRealmBrowserTests

- (void)beforeAll {
    [UIView setAnimationsEnabled:NO];
}

- (void)testSeeAllClassesAndDismiss {
    [tester tapViewWithAccessibilityLabel:@"Realm Browser"];
    [tester waitForViewWithAccessibilityLabel:@"Classes"];

    [tester waitForTappableViewWithAccessibilityLabel:@"Search"];
    [tester waitForTappableViewWithAccessibilityLabel:@"RealmTestClass0, 1000 objects"];
    [tester waitForTappableViewWithAccessibilityLabel:@"RealmTestClass1, 1000 objects"];
    [tester waitForTappableViewWithAccessibilityLabel:@"RealmTestClass2, 1000 objects"];

    [tester tapViewWithAccessibilityLabel:@"Dismiss"];
    [tester waitForTappableViewWithAccessibilityLabel:@"Realm Browser"];
}

- (void)testSeeEntityAndDelete {
    [tester tapViewWithAccessibilityLabel:@"Realm Browser"];
    [tester waitForViewWithAccessibilityLabel:@"Classes"];
    [tester tapViewWithAccessibilityLabel:@"RealmTestClass2, 1000 objects"];

    [tester waitForTimeInterval:1];

    [tester waitForViewWithAccessibilityLabel:@"1000 objects"];
    [tester tapRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] inTableViewWithAccessibilityIdentifier:@"NBNRealmObjectsBrowser"];
    [tester waitForViewWithAccessibilityLabel:@"integerValue, 2039979"];
    [tester waitForViewWithAccessibilityLabel:@"boolValue" traits:UIAccessibilityTraitSelected|UIAccessibilityTraitStaticText];
    [tester waitForViewWithAccessibilityLabel:@"objectReference"];

    [tester tapViewWithAccessibilityLabel:@"Delete Entity"];

    [tester waitForViewWithAccessibilityLabel:@"999 objects"];

    [tester tapViewWithAccessibilityLabel:@"Classes"];
    [tester waitForViewWithAccessibilityLabel:@"RealmTestClass2, 999 objects"];
}

@end
