#import "CCUnitSelectionViewController.h"
#import "Tweak.h"
#import <UIKit/UIScreen+Private.h>

@implementation CCUnitSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor systemBackgroundColor];

    [self _setupSubviews];
}

- (void)_close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_setupSubviews {
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(_close)];
    self.navigationItem.rightBarButtonItem = closeButton;
    self.navigationController.navigationBar.tintColor = [UIColor systemOrangeColor];

    _resultsViewController = [[CCUISearchResultViewController alloc] init];

    // Search controller
    _searchController = [[UISearchController alloc] initWithSearchResultsController:_resultsViewController];
    _searchController.searchResultsUpdater = self;
    _searchController.searchBar.delegate = self;
    _searchController.showsSearchResultsController = YES;
    _searchController.obscuresBackgroundDuringPresentation = NO;
    _searchController.searchBar.placeholder = @"Search all units";
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

    _currencyFooterView = [[CCUICurrencyFooterView alloc] initWithLastUpdatedDate:[[CurrencyCache shared] lastRefreshDate]];
    _currencyFooterView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_currencyFooterView];

    CGFloat footerHeight = 65.0;

    if ([[UIScreen mainScreen] _referenceBounds].size.height <= 735.0) footerHeight = 50.0;
    [NSLayoutConstraint activateConstraints:@[
        [_unitTableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_unitTableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_unitTableView.topAnchor constraintEqualToAnchor:_categoryScrollView.bottomAnchor],

        [_currencyFooterView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_currencyFooterView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_currencyFooterView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [_currencyFooterView.heightAnchor constraintEqualToConstant:footerHeight]
    ]];

    _tableViewBottomToFooterConstraint = [_unitTableView.bottomAnchor constraintEqualToAnchor:_currencyFooterView.topAnchor];
    _tableViewBottomToViewConstraint = [_unitTableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor];
    [self _updateFooterConstraints];
}

- (void)_initializeButtons {
    CCUnitDataProvider *provider = [CCUnitDataProvider sharedInstance];
    for (CalculateUnitCategory *category in provider.unitCollection.categories) {
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

        CalculateUnit *unit = [provider unitForID:provider.inputUnitID];
        if (unit) provider.categoryID = unit.category.categoryID;

        if (category.categoryID == provider.categoryID) {
            button.selected = YES;
            button.backgroundColor = [UIColor systemOrangeColor];

            dispatch_async(dispatch_get_main_queue(), ^{
                CGRect visibleRect = [_categoryScrollView convertRect:button.bounds fromView:button];

                CGFloat offsetX = CGRectGetMidX(visibleRect) - CGRectGetWidth(_categoryScrollView.bounds) / 2;
                offsetX = MAX(0, MIN(offsetX, _categoryScrollView.contentSize.width - _categoryScrollView.bounds.size.width));

                [_categoryScrollView setContentOffset:CGPointMake(offsetX, 0) animated:NO];
            });
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

    [CCUnitDataProvider sharedInstance].categoryID = sender.tag;

    [self _updateFooterConstraints];
    [_unitTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [_unitTableView reloadData];
}

- (void)_updateFooterConstraints {
    if ([CCUnitDataProvider sharedInstance].categoryID == [CCUnitDataProvider sharedInstance].currencyCategory.categoryID) {
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
    CalculateUnitCategory *selectedCategory = [[CCUnitDataProvider sharedInstance] categoryForID:[CCUnitDataProvider sharedInstance].categoryID];
    return selectedCategory.units.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UnitCell"];
    [[UITableViewCell appearance] setTintColor:[UIColor systemOrangeColor]];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UnitCell"];
    }

    CalculateUnitCategory *selectedCategory = [[CCUnitDataProvider sharedInstance] categoryForID:[CCUnitDataProvider sharedInstance].categoryID];
    CalculateUnit *unit = selectedCategory.units[indexPath.row];

    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.textColor = [UIColor labelColor];
    cell.detailTextLabel.textColor = [UIColor systemGray2Color];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.userInteractionEnabled = YES;

    cell.textLabel.text = unit.displayName;
    cell.detailTextLabel.text = unit.shortName;

    BOOL isInput = [self.stagedUnitType isEqualToString:@"editingInputUnit"];
    NSUInteger selectedID, otherID;
    if (isInput) {
        selectedID = [CCUnitDataProvider sharedInstance].inputUnitID;
        otherID = [CCUnitDataProvider sharedInstance].resultUnitID;
    } else {
        selectedID = [CCUnitDataProvider sharedInstance].resultUnitID;
        otherID = [CCUnitDataProvider sharedInstance].inputUnitID;
    }

    if (unit.unitID == selectedID) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.textLabel.textColor = [UIColor systemOrangeColor];
        cell.detailTextLabel.textColor = [UIColor systemOrangeColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userInteractionEnabled = NO;
    } else if (unit.unitID == otherID) {
        cell.textLabel.textColor = [[UIColor labelColor] colorWithAlphaComponent:0.5];
        cell.detailTextLabel.textColor = [[UIColor systemGray2Color] colorWithAlphaComponent:0.5];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userInteractionEnabled = NO;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    CCUnitDataProvider *provider = [CCUnitDataProvider sharedInstance];
    CalculateUnitCategory *selectedCategory = [provider categoryForID:provider.categoryID];
    CalculateUnit *unit = selectedCategory.units[indexPath.row];
    
    BOOL isInput = [self.stagedUnitType isEqualToString:@"editingInputUnit"];
    if (isInput) {
        [provider setInputUnitID:unit.unitID];
    } else {
        [provider setResultUnitID:unit.unitID];
    }

    [_unitTableView reloadData];

    [self updateConversionUI];
    [self _close];
}

- (void)updateConversionUI {
    CalculatorController *calculatorController = [[CCUnitDataProvider sharedInstance] calculatorController];
    DisplayView *displayView = (DisplayView *)([calculatorController getSwiftIvar:@"displayController"].view);

    [displayView.unitConversionDisplayView updateButtonTitles];
    [calculatorController updateConvertedValue];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    _resultsViewController.searchText = searchController.searchBar.text;
}

@end