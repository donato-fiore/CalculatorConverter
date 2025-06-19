#import "CCUIFooterView.h"

@implementation CCUIFooterView

- (instancetype)initWithLastUpdatedDate:(NSDate *)date {
    self = [super init];

    if (self) {
        self.backgroundColor = [UIColor systemGray4Color];

        _logoImageView = [[UIImageView alloc] initWithImage:[self yahooFinanceLogoImage]];
        _logoImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_logoImageView];

        _lastUpdatedLabel = [[UILabel alloc] init];
        _lastUpdatedLabel.font = [UIFont systemFontOfSize:12];
        _lastUpdatedLabel.textColor = [UIColor systemGrayColor];
        _lastUpdatedLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _lastUpdatedLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:_lastUpdatedLabel];

        [NSLayoutConstraint activateConstraints:@[
            [_logoImageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:15],
            [_logoImageView.bottomAnchor constraintEqualToAnchor:self.centerYAnchor],
            [_logoImageView.heightAnchor constraintEqualToConstant:16],
            [_logoImageView.widthAnchor constraintEqualToConstant:111],

            [_lastUpdatedLabel.bottomAnchor constraintEqualToAnchor:self.centerYAnchor],
            [_lastUpdatedLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-15],
            [_lastUpdatedLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:_logoImageView.trailingAnchor constant:10]

        ]];
        _lastUpdatedDate = date;
        _lastUpdatedLabel.text = [self lastUpdatedText];
    }

    return self;
}

- (UIImage *)yahooFinanceLogoImage {
    NSBundle *stocksCoreBundle = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/StocksCore.framework"];
    if (!stocksCoreBundle) {
        NSLog(@"[CCUIFooterView] Failed to load StocksCore framework bundle.");
        return nil;
    }

    UIImage *logoImage = [UIImage imageNamed:@"icon-yahoo-logo" inBundle:stocksCoreBundle compatibleWithTraitCollection:nil];
    if (!logoImage) {
        NSLog(@"[CCUIFooterView] Failed to load Yahoo Finance logo image.");
    }

    return logoImage;
}

- (NSString *)lastUpdatedText {
    if (!_lastUpdatedDate) {
        return @"Last updated: Unknown";
    }

    NSString *formattedDate = [self _formattedStringFromDate:_lastUpdatedDate];
    return [NSString stringWithFormat:@"Last updated: %@", formattedDate];
}

- (NSString *)_formattedStringFromDate:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    if ([calendar isDateInToday:date]) {
        // Time only
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setDateStyle:NSDateFormatterNoStyle];
        [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
        return [timeFormatter stringFromDate:date];
        
    } else if ([calendar isDateInYesterday:date]) {
        return @"Yesterday";
        
    } else {
        // MM/dd/yy
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd/yy"];
        return [dateFormatter stringFromDate:date];
    }
}

@end