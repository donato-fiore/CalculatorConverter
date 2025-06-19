#import <UIKit/UIKit.h>
#import "CCUIFooterView.h"

// , UISearchResultsUpdating, UISearchBarDelegate
@interface CCConversionViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    UISearchController *_searchController;
    UIScrollView *_categoryScrollView;
    UIStackView *_categoryStackView;
    UITableView *_unitTableView;
    CCUIFooterView *_currencyFooterView;

    NSLayoutConstraint *_tableViewBottomToFooterConstraint;
    NSLayoutConstraint *_tableViewBottomToViewConstraint;
}
@property (nonatomic, strong) NSString *stagedUnitType;
@end