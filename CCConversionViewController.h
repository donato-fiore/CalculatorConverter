#import <UIKit/UIKit.h>

@interface CCConversionViewController : UIViewController {
    UISearchController *_searchController;
    UIScrollView *_categoryScrollView;
    UIStackView *_categoryStackView;
}
@property (nonatomic, strong) NSString *selectedUnitIdentifier;
@end