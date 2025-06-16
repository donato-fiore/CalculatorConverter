#import <UIKit/UIKit.h>

@interface CCUnitSelectionDisplayView : UIView {
    UIButton *_changeUnitButton;
    // UILabel *_displayLabel;
    NSNumber *_value;
}

@property (nonatomic, strong) UILabel *displayLabel;
- (void)updateDisplayValue:(NSNumber *)value;

@end