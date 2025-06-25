#import "CCUISearchResultViewController.h"
#import "CCUnitDataProvider.h"
#import "CCUnitSelectionViewController.h"

@implementation CCUISearchResultViewController
@synthesize searchText = _searchText;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchResultCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"SearchResultCell"];
    }

    cell.textLabel.textColor = [UIColor labelColor];
    cell.detailTextLabel.textColor = [UIColor systemGray2Color];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.userInteractionEnabled = YES;
    CalculateUnit *unit;

    if (_searchText.length == 0) {
        unit = [CCUnitDataProvider sharedInstance].recentUnits[indexPath.row];
    } else {
        CalculateUnitCategory *category = [self _filteredUnits][indexPath.section];
        unit = category.units[indexPath.row];
    }

    cell.textLabel.text = unit.displayName;
    cell.detailTextLabel.text = unit.shortName;

    BOOL isInput = [[self _conversionViewController].stagedUnitType isEqualToString:@"editingInputUnit"];
    NSUInteger otherID;
    if (isInput) {
        otherID = [CCUnitDataProvider sharedInstance].resultUnitID;
    } else {
        otherID = [CCUnitDataProvider sharedInstance].inputUnitID;
    }

    if (unit.unitID == otherID) {
        cell.userInteractionEnabled = NO;
        cell.textLabel.textColor = [[UIColor labelColor] colorWithAlphaComponent:0.5];
        cell.detailTextLabel.textColor = [[UIColor systemGray2Color] colorWithAlphaComponent:0.5];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    CalculateUnit *selectedUnit;
    CCUnitDataProvider *provider = [CCUnitDataProvider sharedInstance];
    BOOL isInput = [[self _conversionViewController].stagedUnitType isEqualToString:@"editingInputUnit"];
    if (_searchText.length == 0) {
        selectedUnit = provider.recentUnits[indexPath.row];
    } else {
        CalculateUnitCategory *category = [self _filteredUnits][indexPath.section];
        selectedUnit = category.units[indexPath.row];
    }

    if (!selectedUnit) {
        NSLog(@"[CCUISearchResultViewController] ERROR: Selected unit is nil.");
        return;
    }

    if (isInput) {
        [provider setInputUnitID:selectedUnit.unitID];
    } else {
        [provider setResultUnitID:selectedUnit.unitID];
    }

    [self.tableView reloadData];
    [[self _conversionViewController] updateConversionUI];
    [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (_searchText.length > 0) return nil;

    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor systemGroupedBackgroundColor];

    UILabel *recentLabel = [[UILabel alloc] init];
    recentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    recentLabel.text = @"Recent Units";
    recentLabel.textColor = [UIColor systemGrayColor];
    recentLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
    recentLabel.textAlignment = NSTextAlignmentLeft;
    [headerView addSubview:recentLabel];

    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [clearButton setTitle:@"Clear" forState:UIControlStateNormal];
    [clearButton setTitleColor:[UIColor systemGrayColor] forState:UIControlStateNormal];
    [clearButton addTarget:self action:@selector(_clearRecentUnits) forControlEvents:UIControlEventTouchUpInside];
    clearButton.translatesAutoresizingMaskIntoConstraints = NO;
    clearButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
    [headerView addSubview:clearButton];

    [NSLayoutConstraint activateConstraints:@[
        [recentLabel.leadingAnchor constraintEqualToAnchor:headerView.leadingAnchor constant:20],
        [recentLabel.centerYAnchor constraintEqualToAnchor:headerView.centerYAnchor],
        [recentLabel.trailingAnchor constraintEqualToAnchor:clearButton.leadingAnchor constant:-10],

        [clearButton.trailingAnchor constraintEqualToAnchor:headerView.trailingAnchor constant:-20],
        [clearButton.centerYAnchor constraintEqualToAnchor:headerView.centerYAnchor]
    ]];

    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if (_searchText.length == 0) {
        return [CCUnitDataProvider sharedInstance].recentUnits.count;
    }

    return [self _filteredUnits][section].units.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_searchText.length == 0) return 1;

    return [self _filteredUnits].count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (_searchText.length == 0) return nil;

    CalculateUnitCategory *category = [self _filteredUnits][section];
    return category.name;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (void)setSearchText:(NSString *)searchText {
    _searchText = searchText;
    [self.tableView reloadData];
}

- (void)_clearRecentUnits {
    [[CCUnitDataProvider sharedInstance] clearRecentUnits];
    [self.tableView reloadData];
}

- (CCUnitSelectionViewController *)_conversionViewController {
    return (CCUnitSelectionViewController *)self.presentingViewController;
}

- (NSArray<CalculateUnitCategory *> *)_filteredUnits {
    if (_searchText.length == 0) return nil;

    NSMutableArray *filteredUnits = [NSMutableArray array];
    for (CalculateUnitCategory *category in [CCUnitDataProvider sharedInstance].unitCollection.categories) {
        CalculateUnitCategory *filteredCategory = [category filteredUnitsMatchingString:_searchText];
        if (filteredCategory && filteredCategory.units.count > 0) {
            [filteredUnits addObject:filteredCategory];
        }
    }

    return filteredUnits;
}

@end