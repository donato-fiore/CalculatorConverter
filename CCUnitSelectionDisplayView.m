#import "CCUnitSelectionDisplayView.h"
#import "Tweak.h"

@implementation CCUnitSelectionDisplayView

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self _setupSubviews];
    }
    
    return self;
}

- (void)updateDisplayValue:(NSNumber *)value {
    _value = value;
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;

    NSString *formattedInputValue = [formatter stringFromNumber:value];
    _displayLabel.text = formattedInputValue;
}

- (void)_setupSubviews {
    _changeUnitButton = [[UIButton alloc] init];
    _changeUnitButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_changeUnitButton setTitle:@"USD" forState:UIControlStateNormal];
    [_changeUnitButton setImage:[UIImage systemImageNamed:@"chevron.up.chevron.down"] forState:UIControlStateNormal];
    [_changeUnitButton setTitleColor:[UIColor systemGrayColor] forState:UIControlStateNormal];
    [_changeUnitButton setTitleColor:[UIColor systemFillColor] forState:UIControlStateHighlighted];
    _changeUnitButton.tintColor = [UIColor systemGrayColor];
    _changeUnitButton.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
    [self addSubview:_changeUnitButton];


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
        [_changeUnitButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-5],
        [_changeUnitButton.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [_changeUnitButton.widthAnchor constraintEqualToConstant:80],
        [_changeUnitButton.heightAnchor constraintEqualToConstant:30],

        [_displayLabel.trailingAnchor constraintEqualToAnchor:_changeUnitButton.leadingAnchor constant:-5],
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
}

@end