#import "Tweak.h"
#import <objc/runtime.h>
#import <dlfcn.h>
#import "CCUnitDataProvider.h"

%hook DisplayView
%property (nonatomic, strong) UINavigationBar *navigationBar;
%property (nonatomic, strong) UINavigationItem *navigationItem;
%property (nonatomic, assign) BOOL isUnitConversionMode;
%property (nonatomic, strong) CCConversionDisplayView *unitConversionDisplayView;

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
	UIBarButtonItem *conversionButton = [[UIBarButtonItem alloc] initWithImage:conversionImage style:UIBarButtonItemStylePlain target:self action:@selector(_calculatorConverterButtonTapped)];
	conversionButton.tintColor = [UIColor systemOrangeColor];
	[displayView.navigationItem setRightBarButtonItem:conversionButton animated:NO];

	[CCUnitDataProvider sharedInstance];
}

%new
- (void)_calculatorConverterButtonTapped {
	DisplayView *displayView = self;
	displayView.isUnitConversionMode = !displayView.isUnitConversionMode;

	if (displayView.isUnitConversionMode) {
		if (!displayView.unitConversionDisplayView) {
			displayView.unitConversionDisplayView = [[CCConversionDisplayView alloc] init];
			displayView.unitConversionDisplayView.translatesAutoresizingMaskIntoConstraints = NO;

			[displayView addSubview:displayView.unitConversionDisplayView];
			[NSLayoutConstraint activateConstraints:@[
				[displayView.unitConversionDisplayView.leadingAnchor constraintEqualToAnchor:displayView.leadingAnchor],
				[displayView.unitConversionDisplayView.trailingAnchor constraintEqualToAnchor:displayView.trailingAnchor],
				[displayView.unitConversionDisplayView.topAnchor constraintEqualToAnchor:displayView.navigationBar.bottomAnchor],
				[displayView.unitConversionDisplayView.bottomAnchor constraintEqualToAnchor:displayView.bottomAnchor]
			]];
		}

		UIImage *cancelImage = [UIImage calc_systemImageNamed:@"xmark.circle.fill"];
		UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithImage:cancelImage style:UIBarButtonItemStylePlain target:self action:@selector(_calculatorConverterButtonTapped)];
		cancelButton.tintColor = [UIColor systemOrangeColor];
		[displayView.navigationItem setRightBarButtonItem:cancelButton animated:NO];
	} else {
		[displayView.unitConversionDisplayView removeFromSuperview];
		displayView.unitConversionDisplayView = nil;

		UIImage *conversionImage = [UIImage calc_systemImageNamed:@"arrow.up.arrow.down"];
		UIBarButtonItem *conversionButton = [[UIBarButtonItem alloc] initWithImage:conversionImage style:UIBarButtonItemStylePlain target:self action:@selector(_calculatorConverterButtonTapped)];
		conversionButton.tintColor = [UIColor systemOrangeColor];
		[displayView.navigationItem setRightBarButtonItem:conversionButton animated:NO];
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
		
		[menuController showMenuFromView:displayLabel rect:[displayLabel effectiveTextBounds]];
	}
}

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