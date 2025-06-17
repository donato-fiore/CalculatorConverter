#import <UIKit/UIKit.h>

@interface CCUnitSelectionDisplayView : UIView {
    // UILabel *_displayLabel;
    NSNumber *_value;
}

@property (nonatomic, strong) UIButton *changeUnitButton;

@property (nonatomic, strong) UILabel *displayLabel;
- (void)updateDisplayValue:(NSNumber *)value;

@end