#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "CCUnitConversionDisplayView.h"
#import "CCConversionViewController.h"
#import "CCUnitConversionDataProvider.h"
#import "CCUIFooterView.h"

#import <Extensions/Extensions.h>
#import "CalculateUnits/CalculateUnits.h"

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

@interface CalculatorController : UIViewController
@property (nonatomic, strong) DisplayViewController *accessibilityDisplayController;
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