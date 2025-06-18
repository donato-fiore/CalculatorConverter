#import <UIKit/UIKit.h>

@interface CCUIFooterView : UIView {
    UIImageView *_logoImageView;
    UILabel *_lastUpdatedLabel;
    NSDate *_lastUpdatedDate;
}
- (UIImage *)yahooFinanceLogoImage;
@end