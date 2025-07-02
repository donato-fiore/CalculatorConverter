#import "CCUnitDisplayView.h"
#import "CCUnitDataProvider.h"
#import "Tweak.h"
#import <objc/runtime.h>
#import <substrate.h>

@implementation CCUnitDisplayView

- (instancetype)initWithDisplayValue:(DisplayValue *)displayValue {
    self = [super init];
    
    if (self) {
        [self _setupSubviews];
        [self updateDisplayValue:displayValue];
    }

    NSLog(@"[CCUnitDisplayView] initialized with display value: %@", displayValue);
    
    return self;
}

- (void)updateDisplayValue:(DisplayValue *)value {
    self.displayValue = value;

    CCUnitDataProvider *provider = [CCUnitDataProvider sharedInstance];
    NSNumber *numberValue = [provider.numberFormatter numberFromString:[value valueString]];
    NSString *displayText = [provider.numberFormatter stringFromNumber:numberValue];
    _displayLabel.text = displayText;
}

- (void)_setupSubviews {
    self.changeUnitButton = [[UIButton alloc] init];
    self.changeUnitButton.translatesAutoresizingMaskIntoConstraints = NO;
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
        NSLog(@"[CCUnitDisplayView] Error: DisplayViewController not found in view hierarchy.");
        return;
    }

    displayVC.view.unitConversionDisplayView.activeUnitDisplayView = self;
    [displayVC.view.unitConversionDisplayView updateDisplayLabelColors];

    CalculatorController *controller = [CCUnitDataProvider sharedInstance].calculatorController;
    CalculatorModel *model = [CCUnitDataProvider sharedInstance].calculatorModel;

    // Makes it so that the display value destroys whatever is in the stack
    MSHookIvar<BOOL>(model, "equalsKeyPressed") = YES;

    [controller calculatorModel:model didUpdateDisplayValue:self.displayValue shouldFlashDisplay:NO];
}

@end