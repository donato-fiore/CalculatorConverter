#import <UIKit/UIKit.h>
#import "CCUnitDisplayView.h"

#define kInputUnitActive YES
#define kResultUnitActive NO

@interface CCConversionDisplayView : UIView {
    UIButton *_swapButton;
    UIView *_dividerView;

    CCUnitDisplayView *_inputUnitSelectionDisplayView;
    CCUnitDisplayView *_resultUnitSelectionDisplayView;
}
@property (nonatomic, strong) CCUnitDisplayView *activeUnitDisplayView;
@property (nonatomic, strong) UIView *highlightOverlayView;

- (CCUnitDisplayView *)otherUnitDisplayView;
- (void)didUpdateDisplayValue:(DisplayValue *)value;
- (void)updateDisplayLabelColors;
- (void)updateButtonTitles;

@end