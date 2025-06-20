#import "CCUISearchResultViewController.h"
#import "CCUnitConversionDataProvider.h"
#import "CCConversionViewController.h"

@implementation CCUISearchResultViewController
@synthesize searchText = _searchText;

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section; {
    if (_searchText.length == 0) {
        NSLog(@"[CCUISearchResultViewController] recent units count: %lu", (unsigned long)[CCUnitConversionDataProvider sharedInstance].recentUnits.count);
        return [CCUnitConversionDataProvider sharedInstance].recentUnits.count;
    }

    // NSArray *filteredUnits = [[CCUnitConversionDataProvider sharedInstance] unitsMatchingSearchText:_searchText];
    // return filteredUnits.count;
    return 0;
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

    if (_searchText.length == 0) {
        CalculateUnit *unit = [CCUnitConversionDataProvider sharedInstance].recentUnits[indexPath.row];
        cell.textLabel.text = unit.displayName;
        cell.detailTextLabel.text = unit.shortName;

        BOOL isInput = [[self _conversionViewController].stagedUnitType isEqualToString:@"editingInputUnit"];
        NSUInteger otherID;
        if (isInput) {
            otherID = [CCUnitConversionDataProvider sharedInstance].resultUnitID;
        } else {
            otherID = [CCUnitConversionDataProvider sharedInstance].inputUnitID;
        }

        if (unit.unitID == otherID) {
            cell.userInteractionEnabled = NO;
            cell.textLabel.textColor = [[UIColor labelColor] colorWithAlphaComponent:0.5];
            cell.detailTextLabel.textColor = [[UIColor systemGray2Color] colorWithAlphaComponent:0.5];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    } else {
        // Configure cell with filtered unit
        // NSArray *filteredUnits = [[CCUnitConversionDataProvider sharedInstance] unitsMatchingSearchText:_searchText];
        // CalculateUnit *unit = filteredUnits[indexPath.row];
        // cell.textLabel.text = unit.name;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    CCUnitConversionDataProvider *provider = [CCUnitConversionDataProvider sharedInstance];
    BOOL isInput = [[self _conversionViewController].stagedUnitType isEqualToString:@"editingInputUnit"];
    CalculateUnit *selectedUnit = provider.recentUnits[indexPath.row];
    if (isInput) {
        // provider.inputUnitID = selectedUnit.unitID;
        [provider setInputUnitID:selectedUnit.unitID];
    } else {
        // provider.resultUnitID = selectedUnit.unitID;
        [provider setResultUnitID:selectedUnit.unitID];
    }

    [self.tableView reloadData];
    [[self _conversionViewController] updateConversionUI];
    [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
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

- (void)setSearchText:(NSString *)searchText {
    _searchText = searchText;
    NSLog(@"[CCUISearchResultViewController] Search text set to: %@", searchText);

    [self.tableView reloadData];
}

- (void)_clearRecentUnits {
    [[CCUnitConversionDataProvider sharedInstance] clearRecentUnits];
    [self.tableView reloadData];
}

- (CCConversionViewController *)_conversionViewController {
    return (CCConversionViewController *)self.presentingViewController;
}

@end