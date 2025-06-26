#import "CCConversionDisplayView.h"
#import "CCUnitSelectionViewController.h"
#import "CCUnitDataProvider.h"
#import "Tweak.h"

@implementation CCConversionDisplayView
- (instancetype)init {
    self = [super init];

    if (self) {
        [self _setupSubviews];
    }

    return self;
}

- (void)didUpdateDisplayValue:(DisplayValue *)displayValue direction:(CCUnitConversionDirection)direction {
    NSLog(@"Updating display value: %@, direction: %ld", displayValue.accessibilityStringValue, (long)direction);

    DisplayValue *convertedValue = [[CCUnitDataProvider sharedInstance] convertDisplayValue:displayValue direction:direction];
    [self.activeUnitDisplayView updateDisplayValue:displayValue];
    [self.otherUnitDisplayView updateDisplayValue:convertedValue];
}

- (void)didUpdateDisplayValue:(DisplayValue *)displayValue {
    CCUnitConversionDirection direction = [self.activeUnitDisplayView.accessibilityIdentifier isEqualToString:@"inputUnitDisplayView"];
    [self didUpdateDisplayValue:displayValue direction:direction];
}

- (void)_setupSubviews {
    self.backgroundColor = [UIColor blackColor];

    _swapButton = [[UIButton alloc] init];
    _swapButton.translatesAutoresizingMaskIntoConstraints = NO;
    _swapButton.tintColor = [UIColor systemOrangeColor];
    [_swapButton addTarget:self action:@selector(_swapButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_swapButton setImage:[UIImage systemImageNamed:@"arrow.up.arrow.down"] forState:UIControlStateNormal];

    _dividerView = [[UIView alloc] init];
    _dividerView.translatesAutoresizingMaskIntoConstraints = NO;
    _dividerView.backgroundColor = [[UIColor systemGrayColor] colorWithAlphaComponent:0.5];
    [self addSubview:_dividerView];

    CalculatorModel *model = [[CCUnitDataProvider sharedInstance] calculatorModel];
    DisplayValue *inputDisplayValue = (DisplayValue *)[model getSwiftIvar:@"displayValue"];
    DisplayValue *resultDisplayValue = [[CCUnitDataProvider sharedInstance] convertDisplayValue:inputDisplayValue direction:CCUnitConversionDirectionInputToResult];

    _inputUnitSelectionDisplayView = [[CCUnitDisplayView alloc] initWithDisplayValue:inputDisplayValue];
    _inputUnitSelectionDisplayView.accessibilityIdentifier = @"inputUnitDisplayView";
    [_inputUnitSelectionDisplayView.changeUnitButton addTarget:self action:@selector(changeUnit:) forControlEvents:UIControlEventTouchUpInside];
    _inputUnitSelectionDisplayView.changeUnitButton.accessibilityIdentifier = @"editingInputUnit";
    _inputUnitSelectionDisplayView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_inputUnitSelectionDisplayView];

    _resultUnitSelectionDisplayView = [[CCUnitDisplayView alloc] initWithDisplayValue:resultDisplayValue];
    _resultUnitSelectionDisplayView.accessibilityIdentifier = @"resultUnitDisplayView";
    [_resultUnitSelectionDisplayView.changeUnitButton addTarget:self action:@selector(changeUnit:) forControlEvents:UIControlEventTouchUpInside];
    _resultUnitSelectionDisplayView.changeUnitButton.accessibilityIdentifier = @"editingResultUnit";
    _resultUnitSelectionDisplayView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_resultUnitSelectionDisplayView];
    [self addSubview:_swapButton];

    [self updateButtonTitles];

    [NSLayoutConstraint activateConstraints:@[
        [_swapButton.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [_swapButton.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:15],
        [_swapButton.widthAnchor constraintEqualToConstant:23],
        [_swapButton.heightAnchor constraintEqualToConstant:18],


        [_dividerView.leadingAnchor constraintEqualToAnchor:_swapButton.trailingAnchor constant:10],
        [_dividerView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-5],
        [_dividerView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [_dividerView.heightAnchor constraintEqualToConstant:1],
        
        [_inputUnitSelectionDisplayView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10],
        [_inputUnitSelectionDisplayView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [_inputUnitSelectionDisplayView.bottomAnchor constraintEqualToAnchor:_dividerView.topAnchor constant:5],
        [_inputUnitSelectionDisplayView.topAnchor constraintEqualToAnchor:self.topAnchor constant:5],

        [_resultUnitSelectionDisplayView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10],
        [_resultUnitSelectionDisplayView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [_resultUnitSelectionDisplayView.topAnchor constraintEqualToAnchor:_dividerView.bottomAnchor constant:5],
        [_resultUnitSelectionDisplayView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-5],
    ]];

    self.activeUnitDisplayView = _inputUnitSelectionDisplayView;
    [self updateDisplayLabelColors];
}

- (void)updateButtonTitles {
    CCUnitDataProvider *provider = [CCUnitDataProvider sharedInstance];

    NSString *inputUnitStr = [provider unitForID:provider.inputUnitID].shortName;
    [_inputUnitSelectionDisplayView.changeUnitButton setTitle:inputUnitStr forState:UIControlStateNormal];

    NSString *resultUnitStr = [provider unitForID:provider.resultUnitID].shortName;
    [_resultUnitSelectionDisplayView.changeUnitButton setTitle:resultUnitStr forState:UIControlStateNormal];
}

- (void)updateDisplayLabelColors {
    self.activeUnitDisplayView.displayLabel.textColor = [UIColor whiteColor];
    self.otherUnitDisplayView.displayLabel.textColor = [UIColor systemGrayColor];
}

- (void)changeUnit:(UIButton *)sender {
    CCUnitSelectionViewController *vc = [[CCUnitSelectionViewController alloc] init];
    vc.stagedUnitType = sender.accessibilityIdentifier;
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
	nav.modalPresentationStyle = UIModalPresentationFormSheet;
	[((UIView *)self).window.rootViewController presentViewController:nav animated:YES completion:nil];
}

- (CCUnitDisplayView *)otherUnitDisplayView {
    if ([self.activeUnitDisplayView.accessibilityIdentifier isEqualToString:@"inputUnitDisplayView"]) {
        return _resultUnitSelectionDisplayView;
    } else {
        return _inputUnitSelectionDisplayView;
    }
}

- (void)_swapButtonPressed:(UIButton *)sender {
    NSLog(@"Swap button pressed");
    // Get active display value
    // and then set other display value and perform conversion
    DisplayValue *activeDisplayValue = self.activeUnitDisplayView.displayValue;
    if (!activeDisplayValue) {
        NSLog(@"No active display value to swap");
        return;
    }

    [[self otherUnitDisplayView] updateDisplayValue:activeDisplayValue];
}

@end