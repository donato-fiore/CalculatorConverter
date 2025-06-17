#import "CCConversionViewController.h"

@implementation CCConversionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // self.title = self.selectedUnitIdentifier;
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    [self _setupSubviews];
}

- (void)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_setupSubviews {
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(close)];
    self.navigationItem.rightBarButtonItem = closeButton;

    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    // _searchController.searchResultsUpdater = self;
    _searchController.obscuresBackgroundDuringPresentation = NO;
    _searchController.searchBar.placeholder = @"Search All Units";
    self.navigationItem.searchController = _searchController;
    self.navigationItem.hidesSearchBarWhenScrolling = NO;
}

@end