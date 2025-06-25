#import <UIKit/UIKit.h>

@interface CCUICurrencyFooterView : UIView {
    UIImageView *_logoImageView;
    UILabel *_lastUpdatedLabel;
    NSDate *_lastUpdatedDate;
}
- (instancetype)initWithLastUpdatedDate:(NSDate *)date;
- (UIImage *)yahooFinanceLogoImage;
@end