#import "CCUnitSelectionDisplayView.h"
#import "CCUnitConversionDataProvider.h"
#import "Tweak.h"
#import <objc/runtime.h>
#import <substrate.h>

@implementation CCUnitSelectionDisplayView

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.displayValue = [[objc_getClass("Calculator.DisplayValue") alloc] initWithValue:@"0" userEntered:NO];
        [self _setupSubviews];
    }
    
    return self;
}

// - (void)updateDisplayValue:(NSNumber *)value {
//     _value = value;
//     NSNumberFormatter *formatter = [NSNumberFormatter new];
//     formatter.numberStyle = NSNumberFormatterDecimalStyle;

//     NSString *formattedInputValue = [formatter stringFromNumber:value];
//     _displayLabel.text = formattedInputValue;
// }

- (void)updateDisplayValue:(DisplayValue *)value {
    self.displayValue = value;

    CCUnitConversionDataProvider *provider = [CCUnitConversionDataProvider sharedInstance];
    NSNumber *numberValue = [provider.numberFormatter numberFromString:[value accessibilityStringValue]];
    // NSNumberFormatter *numberFormatter = [CCUnitConversionDataProvider sharedInstance].numberFormatter;
    NSString *displayText = [provider.numberFormatter stringFromNumber:numberValue];
    if ([[provider unitForID:provider.inputUnitID].category isCurrency]) {
        provider.numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;

        displayText = [provider.numberFormatter stringFromNumber:numberValue];

        provider.numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    }
    _displayLabel.text = displayText;
}

- (void)_setupSubviews {
    self.changeUnitButton = [[UIButton alloc] init];
    self.changeUnitButton.translatesAutoresizingMaskIntoConstraints = NO;
    // [self.changeUnitButton setTitle:@"USD" forState:UIControlStateNormal];
    [self.changeUnitButton setImage:[UIImage systemImageNamed:@"chevron.up.chevron.down"] forState:UIControlStateNormal];
    [self.changeUnitButton setTitleColor:[UIColor systemGrayColor] forState:UIControlStateNormal];
    [self.changeUnitButton setTitleColor:[UIColor systemFillColor] forState:UIControlStateHighlighted];
    self.changeUnitButton.tintColor = [UIColor systemGrayColor];
    self.changeUnitButton.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
    [self addSubview:self.changeUnitButton];

    _displayLabel = [[UILabel alloc] init];

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeActiveInputDisplayView:)];
    [_displayLabel addGestureRecognizer:tapGestureRecognizer];
    _displayLabel.userInteractionEnabled = YES;

    _displayLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _displayLabel.textAlignment = NSTextAlignmentRight;
    _displayLabel.adjustsFontSizeToFitWidth = YES;
    _displayLabel.minimumScaleFactor = 0.1;
    [_displayLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [_displayLabel setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    _displayLabel.lineBreakMode = NSLineBreakByClipping;
    _displayLabel.font = [UIFont systemFontOfSize:80 weight:UIFontWeightThin];
    _displayLabel.text = @"0";
    [self addSubview:_displayLabel];

    [NSLayoutConstraint activateConstraints:@[
        [self.changeUnitButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-5],
        [self.changeUnitButton.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [self.changeUnitButton.widthAnchor constraintEqualToConstant:80],
        [self.changeUnitButton.heightAnchor constraintEqualToConstant:30],

        [_displayLabel.trailingAnchor constraintEqualToAnchor:self.changeUnitButton.leadingAnchor constant:-5],
        [_displayLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [_displayLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10],
        [_displayLabel.topAnchor constraintEqualToAnchor:self.topAnchor],
        [_displayLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
    ]];
}

- (void)changeActiveInputDisplayView:(UITapGestureRecognizer *)sender {
    DisplayViewController *displayVC = (DisplayViewController *)[self _viewControllerForAncestor];
    if (!displayVC) {
        NSLog(@"Error: DisplayViewController not found in view hierarchy.");
        return;
    }

    displayVC.view.unitConversionDisplayView.activeUnitDisplayView = self;
    [displayVC.view.unitConversionDisplayView updateDisplayLabelColors];

    CalculatorController *controller = [(id)([UIApplication sharedApplication].delegate) getSwiftIvar:@"controller"];
    if (!controller) {
        NSLog(@"[CCUnitSelectionDisplayView] CalculatorController not found in app delegate.");
        return;
    }

    CalculatorModel *model = (CalculatorModel *)[controller getSwiftIvar:@"model"];
    if (!model) {
        NSLog(@"[Tweak] CalculatorModel not found in CalculatorController.");
        return;
    }
    MSHookIvar<BOOL>(model, "equalsKeyPressed") = YES;

    [controller calculatorModel:model didUpdateDisplayValue:self.displayValue shouldFlashDisplay:NO];
}

@end