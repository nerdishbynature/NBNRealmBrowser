# NBNRealmBrowser

NBNRealmBrowser is the iOS companion to the Realm Browser for Mac. It displays all information for your current realm for debugging purposes.

![](./readme/RealmBrowser.gif)

[![CI Status](http://img.shields.io/travis/nerdishbynature/NBNRealmBrowser.svg?style=flat)](https://travis-ci.org/nerdishbynature/NBNRealmBrowser)
[![Version](https://img.shields.io/cocoapods/v/NBNRealmBrowser.svg?style=flat)](http://cocoadocs.org/docsets/NBNRealmBrowser)
[![License](https://img.shields.io/cocoapods/l/NBNRealmBrowser.svg?style=flat)](http://cocoadocs.org/docsets/NBNRealmBrowser)
[![Platform](https://img.shields.io/cocoapods/p/NBNRealmBrowser.svg?style=flat)](http://cocoadocs.org/docsets/NBNRealmBrowser)

## Try it out now!

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

NBNRealmBrowser is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "NBNRealmBrowser"


## Usage

`NBNRealmBrowser` was built using a UISplitViewController and it has to be presented modally.

I created a convenient method for getting the ViewController you should present.

The basic usage is as follows:

```obj-c
#import "NBNViewController.h"
#import <NBNRealmBrowser/NBNRealmBrowser.h>

@interface NBNViewController ()

@end

@implementation NBNViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setupRealmBrowserButton];
}

- (void)setupRealmBrowserButton {
  UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Realm Browser"
  style:UIBarButtonItemStylePlain
  target:self
  action:@selector(openRealmBrowser:)];
  self.navigationItem.rightBarButtonItem = barButtonItem;
}

- (void)openRealmBrowser:(id)sender {
  [self presentViewController:[NBNRealmBrowser browser] animated:YES completion:nil];
}

@end
```

## Known Issues

* Due to the UISplitViewController nature (you shouldn't present it modally) dismissing the browser in Portrait mode leads to an unusable app. A proposed workaround is to use it in Landscape only. NOTE: This effects iPad projects only.

## License

NBNRealmBrowser is available under the MIT license. See the LICENSE file for more info.
