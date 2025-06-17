#import <UIKit/UIKit.h>
// , UISearchResultsUpdating, UISearchBarDelegate
@interface CCConversionViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    UISearchController *_searchController;
    UIScrollView *_categoryScrollView;
    UIStackView *_categoryStackView;
    UITableView *_unitTableView;
}
@property (nonatomic, strong) NSString *selectedUnitIdentifier;
@end