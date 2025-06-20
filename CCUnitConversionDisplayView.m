#import "CCUnitConversionDisplayView.h"
#import "Tweak.h"

@implementation CCUnitConversionDisplayView

- (instancetype)init {
    self = [super init];

    if (self) {
        [self _setupSubviews];
    }

    return self;
}

- (void)setActiveInputValue:(NSNumber *)value {
    [self.activeUnitDisplayView updateDisplayValue:value]; 

    NSNumber *convertedValue = [[CCUnitConversionDataProvider sharedInstance] convertValue:value];
    if ([self.activeUnitDisplayView.accessibilityIdentifier isEqualToString:@"inputUnitDisplayView"]) {
        [_resultUnitSelectionDisplayView updateDisplayValue:convertedValue];
    } else {
        [_inputUnitSelectionDisplayView updateDisplayValue:convertedValue];
    }
}

- (void)_setupSubviews {
    self.backgroundColor = [UIColor blackColor];

    _swapButton = [[UIButton alloc] init];
    _swapButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_swapButton setImage:[UIImage systemImageNamed:@"arrow.up.arrow.down"] forState:UIControlStateNormal];
    _swapButton.tintColor = [UIColor systemOrangeColor];
    [self addSubview:_swapButton];

    _dividerView = [[UIView alloc] init];
    _dividerView.translatesAutoresizingMaskIntoConstraints = NO;
    _dividerView.backgroundColor = [[UIColor systemGrayColor] colorWithAlphaComponent:0.5];
    [self addSubview:_dividerView];

    _inputUnitSelectionDisplayView = [[CCUnitSelectionDisplayView alloc] init];
    _inputUnitSelectionDisplayView.accessibilityIdentifier = @"inputUnitDisplayView";
    [_inputUnitSelectionDisplayView.changeUnitButton addTarget:self action:@selector(changeUnit:) forControlEvents:UIControlEventTouchUpInside];
    _inputUnitSelectionDisplayView.changeUnitButton.accessibilityIdentifier = @"editingInputUnit";
    _inputUnitSelectionDisplayView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_inputUnitSelectionDisplayView];

    _resultUnitSelectionDisplayView = [[CCUnitSelectionDisplayView alloc] init];
    _resultUnitSelectionDisplayView.accessibilityIdentifier = @"resultUnitDisplayView";
    [_resultUnitSelectionDisplayView.changeUnitButton addTarget:self action:@selector(changeUnit:) forControlEvents:UIControlEventTouchUpInside];
    _resultUnitSelectionDisplayView.changeUnitButton.accessibilityIdentifier = @"editingResultUnit";
    _resultUnitSelectionDisplayView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_resultUnitSelectionDisplayView];

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
    CCUnitConversionDataProvider *provider = [CCUnitConversionDataProvider sharedInstance];

    NSString *inputUnitStr = [provider unitForID:provider.inputUnitID].shortName;
    [_inputUnitSelectionDisplayView.changeUnitButton setTitle:inputUnitStr forState:UIControlStateNormal];

    NSString *resultUnitStr = [provider unitForID:provider.resultUnitID].shortName;
    [_resultUnitSelectionDisplayView.changeUnitButton setTitle:resultUnitStr forState:UIControlStateNormal];
}

- (void)updateDisplayLabelColors {
    if ([self.activeUnitDisplayView.accessibilityIdentifier isEqualToString:@"inputUnitDisplayView"]) {
        _inputUnitSelectionDisplayView.displayLabel.textColor = [UIColor whiteColor];
        _resultUnitSelectionDisplayView.displayLabel.textColor = [UIColor systemGrayColor];
    } else {
        _inputUnitSelectionDisplayView.displayLabel.textColor = [UIColor systemGrayColor];
        _resultUnitSelectionDisplayView.displayLabel.textColor = [UIColor whiteColor];
    }
}

- (void)changeUnit:(UIButton *)sender {
    CCConversionViewController *vc = [[CCConversionViewController alloc] init];
    vc.stagedUnitType = sender.accessibilityIdentifier;
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
	nav.modalPresentationStyle = UIModalPresentationFormSheet;
	[((UIView *)self).window.rootViewController presentViewController:nav animated:YES completion:nil];
}

@end