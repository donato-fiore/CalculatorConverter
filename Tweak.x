#import "Tweak.h"
#import <objc/runtime.h>
#import <dlfcn.h>
// 
// #import "CCConversionViewController.h"
// #import "CCUnitConversionDataProvider.h"
// #import "CCUIFooterView.h"

// #import "CalculateUnits/CalculateUnits.h"


%hook DisplayView
%property (nonatomic, strong) UINavigationBar *navigationBar;
%property (nonatomic, strong) UINavigationItem *navigationItem;
%property (nonatomic, assign) BOOL isUnitConversionMode;
%property (nonatomic, strong) CCUnitConversionDisplayView *unitConversionDisplayView;

- (void)didMoveToSuperview {
	%orig;

	DisplayView *displayView = self;

	// The navigation bar will exist if calculatorhistory is also installed.
	if (!displayView.navigationBar) {
		displayView.navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
		UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
		[appearance configureWithTransparentBackground];
		displayView.navigationBar.standardAppearance = appearance;

		displayView.navigationItem = [[UINavigationItem alloc] init];
		[displayView.navigationBar setItems:@[displayView.navigationItem]];
		
		[self addSubview:displayView.navigationBar];
	}

	UIImage *conversionImage = [UIImage calc_systemImageNamed:@"arrow.up.arrow.down"];
	UIBarButtonItem *conversionButton = [[UIBarButtonItem alloc] initWithImage:conversionImage style:UIBarButtonItemStylePlain target:self action:@selector(_changeUnitConversionMode)];
	conversionButton.tintColor = [UIColor systemOrangeColor];
	[displayView.navigationItem setRightBarButtonItem:conversionButton animated:NO];

	displayView.unitConversionDisplayView = [[CCUnitConversionDisplayView alloc] init];
	displayView.unitConversionDisplayView.translatesAutoresizingMaskIntoConstraints = NO;
	displayView.unitConversionDisplayView.hidden = YES;

	[displayView addSubview:displayView.unitConversionDisplayView];
	[NSLayoutConstraint activateConstraints:@[
		[displayView.unitConversionDisplayView.leadingAnchor constraintEqualToAnchor:displayView.leadingAnchor],
		[displayView.unitConversionDisplayView.trailingAnchor constraintEqualToAnchor:displayView.trailingAnchor],
		[displayView.unitConversionDisplayView.topAnchor constraintEqualToAnchor:displayView.navigationBar.bottomAnchor],
		[displayView.unitConversionDisplayView.bottomAnchor constraintEqualToAnchor:displayView.bottomAnchor]
	]];
}

%new
- (void)_changeUnitConversionMode {
	DisplayView *displayView = self;

	displayView.isUnitConversionMode = !displayView.isUnitConversionMode;

	if (displayView.isUnitConversionMode) {
		UIImage *cancelImage = [UIImage calc_systemImageNamed:@"xmark.circle.fill"];
		UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithImage:cancelImage style:UIBarButtonItemStylePlain target:self action:@selector(_changeUnitConversionMode)];
		cancelButton.tintColor = [UIColor systemOrangeColor];
		[displayView.navigationItem setRightBarButtonItem:cancelButton animated:NO];

		displayView.unitConversionDisplayView.hidden = NO;
	} else {
		UIImage *conversionImage = [UIImage calc_systemImageNamed:@"arrow.up.arrow.down"];
		UIBarButtonItem *conversionButton = [[UIBarButtonItem alloc] initWithImage:conversionImage style:UIBarButtonItemStylePlain target:self action:@selector(_changeUnitConversionMode)];
		conversionButton.tintColor = [UIColor systemOrangeColor];
		[displayView.navigationItem setRightBarButtonItem:conversionButton animated:NO];
		
		displayView.unitConversionDisplayView.hidden = YES;
	}
}

%end

%hook DisplayViewController

- (void)longPress:(UILongPressGestureRecognizer *)gestureRecognizer {
	DisplayView *displayView = ((DisplayViewController *)self).view;
	if (!displayView.isUnitConversionMode) {
		%orig;
		return;
	}

	if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
		[self becomeFirstResponder];

		UIMenuController *menuController = [UIMenuController sharedMenuController];
		UILabel *displayLabel = displayView.unitConversionDisplayView.activeUnitDisplayView.displayLabel;
		NSLog(@"displayLabel: %@", displayLabel);
		NSLog(@"displayLabel bounds: %@", NSStringFromCGRect(displayLabel.bounds));

		CGRect effectiveBounds = [displayLabel effectiveTextBounds];
		CGRect finalFrame = CGRectMake(
			effectiveBounds.origin.x / 2,
			displayLabel.frame.origin.y + effectiveBounds.origin.y,
			effectiveBounds.size.width,
			effectiveBounds.size.height
		);
		// NSLog(@"effectiveBounds: %@", NSStringFromCGRect(effectiveBounds));

		// // CGRect offsetBounds = CGRectOffset(displayLabel.frame, effectiveBounds.origin.x, effectiveBounds.origin.y);
		// CGRect offsetBounds = CGRectOffset(displayLabel.frame, effectiveBounds.origin.x - displayLabel.bounds.origin.x, effectiveBounds.origin.y - displayLabel.bounds.origin.y);
		// // NSLog(@"offsetBounds: %@", NSStringFromCGRect(offsetBounds));
		[menuController showMenuFromView:displayLabel rect:finalFrame];
	}
}

// - (BOOL)becomeFirstResponder {
// 	DisplayViewController *displayViewController = (DisplayViewController *)self;
// 	DisplayView *displayView = displayViewController.view;
// 	if (!displayView.isUnitConversionMode) {
// 		return %orig;
// 	}

// 	struct objc_super superInfo = { displayViewController, [displayViewController superclass] };
// 	BOOL result = ((BOOL (*)(struct objc_super *, SEL))objc_msgSendSuper)(&superInfo, @selector(becomeFirstResponder));
// 	CCUnitConversionDisplayView *unitConversionDisplayView = displayView.unitConversionDisplayView;

// 	if (unitConversionDisplayView.highlighted) {
// 		if (unitConversionDisplayView.highlightOverlayView) return result;
// 		CGRect effectiveBounds = [unitConversionDisplayView.activeUnitDisplayView.displayLabel effectiveTextBounds];

// 		CGRect tmpFrame1 = CGRectOffset(unitConversionDisplayView.activeUnitDisplayView.displayLabel.frame, effectiveBounds.origin.x, effectiveBounds.origin.y);
// 		CGRect tmpFrame2 = [unitConversionDisplayView convertRect:tmpFrame1 fromCoordinateSpace:unitConversionDisplayView.activeUnitDisplayView];

// 		NSLog(@"effectiveBounds: %@", NSStringFromCGRect(effectiveBounds));
// 		NSLog(@"tmpFrame1: %@", NSStringFromCGRect(tmpFrame1));
// 		NSLog(@"tmpFrame2: %@", NSStringFromCGRect(tmpFrame2));
// 	}

// 	if (!unitConversionDisplayView.highlightOverlayView) return result;
// 	[unitConversionDisplayView.highlightOverlayView removeFromSuperview];



// 	return result;
// }

- (void)copy:(id)sender {
	DisplayView *displayView = ((DisplayViewController *)self).view;
	if (!displayView.isUnitConversionMode) {
		%orig;
		return;
	}

	if (!displayView.unitConversionDisplayView.activeUnitDisplayView) {
		return;
	}

	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	[pasteboard setString:displayView.unitConversionDisplayView.activeUnitDisplayView.displayLabel.text];
}

%end

%hook CalculatorController

// static void (*orig_didUpdateDisplayValue_ptr)(id, SEL, id, DisplayValue *, BOOL) = NULL;

%new
- (void)setDisplayValue:(DisplayValue *)displayValue shouldFlashDisplay:(BOOL)shouldFlashDisplay {
    CalculatorModel *model = (CalculatorModel *)[self getSwiftIvar:@"model"];
    if (!model) {
        NSLog(@"[Tweak] CalculatorModel not found in CalculatorController.");
        return;
    }

	[self calculatorModel:model didUpdateDisplayValue:displayValue shouldFlashDisplay:shouldFlashDisplay];
}

- (void)calculatorModel:(id)calculatorModel didUpdateDisplayValue:(DisplayValue *)displayValue shouldFlashDisplay:(BOOL)shouldFlashDisplay {
	%orig;

	NSLog(@"[Tweak] displayValue: %@", displayValue);

    DisplayView *displayView = ((DisplayViewController *)[self getSwiftIvar:@"displayController"]).view;
    if (!displayView.isUnitConversionMode) return;
    [displayView.unitConversionDisplayView didUpdateDisplayValue:displayValue];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
	%orig;
	DisplayView *displayView = ((DisplayViewController *)[self getSwiftIvar:@"displayController"]).view;
	if (!displayView) return;
	
	if (size.width > size.height) {	// landscape
		displayView.navigationBar.hidden = YES;
		displayView.unitConversionDisplayView.hidden = YES;
	} else {	// portrait
		displayView.navigationBar.hidden = NO;
		if (displayView.isUnitConversionMode) {
			displayView.unitConversionDisplayView.hidden = NO;
		}
	}
}

%end


__attribute__((constructor))
static void init_zzz_CalculatorConverter_Tweak(void) {
	%init(DisplayView = objc_getClass("Calculator.DisplayView"),
		  DisplayViewController = objc_getClass("Calculator.DisplayViewController"),
		  CalculatorController = objc_getClass("Calculator.CalculatorController"));
}