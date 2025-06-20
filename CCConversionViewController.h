#import <UIKit/UIKit.h>
#import "CCUIFooterView.h"
#import "CCUISearchResultViewController.h"

@interface CCConversionViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate> {
    UISearchController *_searchController;
    UIScrollView *_categoryScrollView;
    UIStackView *_categoryStackView;
    UITableView *_unitTableView;
    CCUIFooterView *_currencyFooterView;

    CCUISearchResultViewController *_resultsViewController;

    NSLayoutConstraint *_tableViewBottomToFooterConstraint;
    NSLayoutConstraint *_tableViewBottomToViewConstraint;
}
@property (nonatomic, strong) NSString *stagedUnitType;
- (void)updateConversionUI;
@end