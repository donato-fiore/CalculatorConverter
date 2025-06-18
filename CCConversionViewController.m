#import "CCConversionViewController.h"
#import "Tweak.h"

@implementation CCConversionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

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

    [self _initializeButtons];

    // Table view
    _unitTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _unitTableView.translatesAutoresizingMaskIntoConstraints = NO;
    _unitTableView.dataSource = self;
    _unitTableView.delegate = self;
    _unitTableView.backgroundColor = [UIColor systemBackgroundColor];
    [self.view addSubview:_unitTableView];

    _currencyFooterView = [[CCUIFooterView alloc] init];
    _currencyFooterView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_currencyFooterView];

    [NSLayoutConstraint activateConstraints:@[
        [_unitTableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_unitTableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_unitTableView.topAnchor constraintEqualToAnchor:_categoryScrollView.bottomAnchor],

        [_currencyFooterView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_currencyFooterView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_currencyFooterView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [_currencyFooterView.heightAnchor constraintEqualToConstant:65]
    ]];

    _tableViewBottomToFooterConstraint = [_unitTableView.bottomAnchor constraintEqualToAnchor:_currencyFooterView.topAnchor];
    _tableViewBottomToViewConstraint = [_unitTableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor];
    [self _updateFooterConstraints];
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

    sender.selected = YES;
    sender.backgroundColor = [UIColor systemOrangeColor];

    [CCUnitConversionDataProvider sharedInstance].categoryID = sender.tag;

    [self _updateFooterConstraints];
    [_unitTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [_unitTableView reloadData];
}

- (void)_updateFooterConstraints {
    if ([CCUnitConversionDataProvider sharedInstance].categoryID == [CCUnitConversionDataProvider sharedInstance].currencyCategory.categoryID) {
        _currencyFooterView.hidden = NO;
        _tableViewBottomToFooterConstraint.active = YES;
        _tableViewBottomToViewConstraint.active = NO;
    }
    else {
        _currencyFooterView.hidden = YES;
        _tableViewBottomToFooterConstraint.active = NO;
        _tableViewBottomToViewConstraint.active = YES;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    CalculateUnitCategory *selectedCategory = [[CCUnitConversionDataProvider sharedInstance] categoryForID:[CCUnitConversionDataProvider sharedInstance].categoryID];
    return selectedCategory.units.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UnitCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UnitCell"];
    }
    
    CalculateUnitCategory *selectedCategory = [[CCUnitConversionDataProvider sharedInstance] categoryForID:[CCUnitConversionDataProvider sharedInstance].categoryID];
    CalculateUnit *unit = selectedCategory.units[indexPath.row];
    cell.textLabel.text = unit.displayName;
    cell.detailTextLabel.text = unit.shortName;
    cell.detailTextLabel.textColor = [UIColor systemGray2Color];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

@end