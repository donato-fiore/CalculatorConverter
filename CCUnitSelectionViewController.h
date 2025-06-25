#import <UIKit/UIKit.h>
#import "CCUICurrencyFooterView.h"
#import "CCUISearchResultViewController.h"

@interface CCUnitSelectionViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate> {
    UISearchController *_searchController;
    UIScrollView *_categoryScrollView;
    UIStackView *_categoryStackView;
    UITableView *_unitTableView;
    CCUICurrencyFooterView *_currencyFooterView;

    CCUISearchResultViewController *_resultsViewController;

    NSLayoutConstraint *_tableViewBottomToFooterConstraint;
    NSLayoutConstraint *_tableViewBottomToViewConstraint;
}
@property (nonatomic, strong) NSString *stagedUnitType;
- (void)updateConversionUI;
@end