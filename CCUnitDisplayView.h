#import <UIKit/UIKit.h>

@class DisplayValue;

@interface CCUnitDisplayView : UIView
@property (nonatomic, strong) DisplayValue *displayValue;
@property (nonatomic, strong) UIButton *changeUnitButton;
@property (nonatomic, strong) UILabel *displayLabel;

- (void)updateDisplayValue:(DisplayValue *)value;

@end