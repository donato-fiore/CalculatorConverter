#import <UIKit/UIKit.h>

@interface CCUnitSelectionDisplayView : UIView {
    UIButton *_changeUnitButton;
    UILabel *_displayLabel;
    NSNumber *_value;
}

- (void)updateDisplayValue:(NSNumber *)value;

@end