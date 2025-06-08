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
    // For testing, write to both input and result display views


    NSNumberFormatter *formatter = [NSNumberFormatter new];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;

    NSString *formattedInputValue = [formatter stringFromNumber:value];
    [_inputUnitSelectionDisplayView updateDisplayValue:formattedInputValue];
    [_resultUnitSelectionDisplayView updateDisplayValue:formattedInputValue];
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
    _inputUnitSelectionDisplayView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_inputUnitSelectionDisplayView];

    _resultUnitSelectionDisplayView = [[CCUnitSelectionDisplayView alloc] init];
    _resultUnitSelectionDisplayView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_resultUnitSelectionDisplayView];

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
}

@end