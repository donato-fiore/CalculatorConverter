#import "CCConversionViewController.h"
#import "Tweak.h"

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

    // Search controller
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    // _searchController.searchResultsUpdater = self;
    _searchController.obscuresBackgroundDuringPresentation = NO;
    _searchController.searchBar.placeholder = @"Search All Units";
    self.navigationItem.searchController = _searchController;
    self.navigationItem.hidesSearchBarWhenScrolling = NO;

    // Category scroll view
    _categoryScrollView = [[UIScrollView alloc] init];
    _categoryScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _categoryScrollView.showsHorizontalScrollIndicator = NO;
    _categoryScrollView.backgroundColor = [UIColor systemBackgroundColor];
    [self.view addSubview:_categoryScrollView];

    _categoryStackView = [[UIStackView alloc] init];
    _categoryStackView.axis = UILayoutConstraintAxisHorizontal;
    _categoryStackView.distribution = UIStackViewDistributionEqualSpacing;
    _categoryStackView.spacing = 5;
    _categoryStackView.alignment = UIStackViewAlignmentCenter;
    _categoryStackView.translatesAutoresizingMaskIntoConstraints = NO;

    [_categoryScrollView addSubview:_categoryStackView];

    [NSLayoutConstraint activateConstraints:@[
        [_categoryScrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_categoryScrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_categoryScrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [_categoryScrollView.heightAnchor constraintEqualToConstant:30],

        [_categoryStackView.leadingAnchor constraintEqualToAnchor:_categoryScrollView.contentLayoutGuide.leadingAnchor
                                                         constant:20],
        [_categoryStackView.trailingAnchor constraintEqualToAnchor:_categoryScrollView.contentLayoutGuide.trailingAnchor
                                                          constant:-20],
        [_categoryStackView.topAnchor constraintEqualToAnchor:_categoryScrollView.contentLayoutGuide.topAnchor],
        [_categoryStackView.bottomAnchor constraintEqualToAnchor:_categoryScrollView.contentLayoutGuide.bottomAnchor],
        [_categoryStackView.heightAnchor constraintEqualToAnchor:_categoryScrollView.heightAnchor]
    ]];

    // Initialize buttons for each category
    [self _initializeButtons];
}

- (void)_initializeButtons {
    NSArray<CalculateUnitCategory *> *categories = [CCUnitConversionDataProvider sharedInstance].unitCollection.categories;
    for (CalculateUnitCategory *category in categories) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = category.categoryID;
        [button.titleLabel setFont:[UIFont systemFontOfSize:12 weight:UIFontWeightRegular]];
        [button addTarget:self action:@selector(_categoryButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:category.name forState:UIControlStateNormal];
        [button setTitleColor:[UIColor systemOrangeColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];

        button.contentEdgeInsets = UIEdgeInsetsMake(4, 10, 4, 10);
        button.layer.cornerRadius = 23 / 2;
        button.clipsToBounds = YES;

        [_categoryStackView addArrangedSubview:button];

        if (category.categoryID == [CCUnitConversionDataProvider sharedInstance].categoryID) {
            button.selected = YES;
            button.backgroundColor = [UIColor systemOrangeColor];
        }
    }
}

- (void)_categoryButtonTapped:(UIButton *)sender {
    // Deselect all buttons
    for (UIButton *button in _categoryStackView.arrangedSubviews) {
        button.selected = NO;
        button.backgroundColor = [UIColor clearColor];
    }

    // Select the tapped button
    sender.selected = YES;
    sender.backgroundColor = [UIColor systemOrangeColor];

    // Update the selected category ID
    [CCUnitConversionDataProvider sharedInstance].categoryID = sender.tag;
}

@end