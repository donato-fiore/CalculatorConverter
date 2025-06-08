#import "Tweak.h"

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

%hook CalculatorController

- (void)calculatorModel:(id /* Calculator.CalculatorModel */)calculatorModel didUpdateDisplayValue:(DisplayValue *)displayValue shouldFlashDisplay:(BOOL)shouldFlashDisplay {
	%orig;

	CalculatorController *controller = (CalculatorController *)self;
	DisplayView *displayView = controller.accessibilityDisplayController.view;
	NSNumber *displayValueNumber = [[NSNumberFormatter new] numberFromString:[displayValue accessibilityStringValue]];
	[displayView.unitConversionDisplayView setActiveInputValue:displayValueNumber];
}

%end

%ctor {
	%init(DisplayView = objc_getClass("Calculator.DisplayView"), 
		  CalculatorController = objc_getClass("Calculator.CalculatorController"));
}