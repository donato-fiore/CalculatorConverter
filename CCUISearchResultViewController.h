#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CCUnitConversionDataProvider.h"

@interface CCUISearchResultViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate> {
    NSString *_searchText;
}
@property (nonatomic, strong) NSString *searchText;
@end