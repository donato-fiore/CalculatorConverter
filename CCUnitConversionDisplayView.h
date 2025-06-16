#import <UIKit/UIKit.h>
#import "CCUnitSelectionDisplayView.h"

#define kInputUnitActive YES
#define kResultUnitActive NO

@interface CCUnitConversionDisplayView : UIView {
    UIButton *_swapButton;
    UIView *_dividerView;

    CCUnitSelectionDisplayView *_inputUnitSelectionDisplayView;
    CCUnitSelectionDisplayView *_resultUnitSelectionDisplayView;
}
@property (nonatomic, strong) CCUnitSelectionDisplayView *activeUnitDisplayView;

- (void)setActiveInputValue:(NSNumber *)value;
- (void)updateDisplayLabelColors;

@end