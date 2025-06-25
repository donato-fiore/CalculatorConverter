#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Extensions/Extensions.h>

#import "CCUnitConversionDisplayView.h"

@interface UIView (Private)
- (UIViewController *)_viewControllerForAncestor;
@end

@interface DisplayValue : NSObject
- (NSString *)accessibilityStringValue;
@end

@interface DisplayView : UIView
@property (nonatomic, strong) UILabel *accessibilityValueLabel;
@end

@interface DisplayViewController : UIViewController
@property (nonatomic, strong) DisplayView *view;
@end

@interface CalculatorModel : NSObject
@end

@interface CalculatorController : UIViewController
@property (nonatomic, strong) DisplayViewController *accessibilityDisplayController;
- (void)calculatorModel:(CalculatorModel *)model didUpdateDisplayValue:(DisplayValue *)displayValue shouldFlashDisplay:(BOOL)shouldFlash;
@end

@interface CalculatorNumberFormatter : NSNumberFormatter
@end

@interface DisplayView (CalculatorHistory)
@property (nonatomic, strong) UINavigationBar *navigationBar;
@property (nonatomic, strong) UINavigationItem *navigationItem;
@end

@interface DisplayView (CalculatorUnitConversion)
@property (nonatomic, strong) CCUnitConversionDisplayView *unitConversionDisplayView;
@property (nonatomic, assign) BOOL isUnitConversionMode;
- (void)_presentConversionViewController;
@end

@interface DisplayValue (CalculatorConverter)
- (instancetype)initWithValue:(NSString *)value userEntered:(BOOL)userEntered;
- (NSString *)valueString;
- (BOOL)isUserEntered;
@end

@interface CalculatorNumberFormatter (CalculatorConverter)
- (instancetype)initWithMaximumDigitCount:(NSUInteger)maximumDigitCount;
@end

@interface CalculatorController (CalculatorConverter)
- (void)setDisplayValue:(DisplayValue *)displayValue shouldFlashDisplay:(BOOL)shouldFlashDisplay;
@end