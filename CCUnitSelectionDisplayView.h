#import <UIKit/UIKit.h>

@class DisplayValue;

@interface CCUnitSelectionDisplayView : UIView {
    // UILabel *_displayLabel;
    // NSNumber *_value;
}
@property (nonatomic, strong) DisplayValue *displayValue;
@property (nonatomic, strong) UIButton *changeUnitButton;
@property (nonatomic, strong) UILabel *displayLabel;

// - (void)updateDisplayValue:(NSNumber *)value;
- (void)updateDisplayValue:(DisplayValue *)value;

@end