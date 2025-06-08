#import <UIKit/UIKit.h>
#import "CCUnitSelectionDisplayView.h"

@interface CCUnitConversionDisplayView : UIView {
    UIButton *_swapButton;
    UIView *_dividerView;

    CCUnitSelectionDisplayView *_inputUnitSelectionDisplayView;
    CCUnitSelectionDisplayView *_resultUnitSelectionDisplayView;
}

// - (void)setInputDisplayValue:(NSString *)inputDisplayText;
- (void)setActiveInputValue:(NSNumber *)value;

@end