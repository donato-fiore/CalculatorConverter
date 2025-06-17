#import <UIKit/UIKit.h>

@interface CCConversionViewController : UIViewController {
    UISearchController *_searchController;
    UICollectionView *_collectionView;
}
@property (nonatomic, strong) NSString *selectedUnitIdentifier;
@end