#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CCUnitDataProvider.h"

@interface CCUISearchResultViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate> {
    NSString *_searchText;
}
@property (nonatomic, strong) NSString *searchText;
@end