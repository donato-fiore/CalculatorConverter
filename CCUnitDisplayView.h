#import <UIKit/UIKit.h>

@class DisplayValue;

@interface CCUnitDisplayView : UIView
@property (nonatomic, strong) DisplayValue *displayValue;
@property (nonatomic, strong) UIButton *changeUnitButton;
@property (nonatomic, strong) UILabel *displayLabel;

- (instancetype)initWithDisplayValue:(DisplayValue *)displayValue;
- (void)updateDisplayValue:(DisplayValue *)value;

@end