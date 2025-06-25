#import "UILabel+EffectiveTextBounds.h"

@implementation UILabel (EffectiveTextBounds)

- (CGRect)effectiveTextBounds {
    NSString *text = self.text;
    if (text.length == 0) {
        return CGRectZero;
    }

    NSDictionary *attributes = @{NSFontAttributeName: self.font};
    CGSize textSize = [text sizeWithAttributes:attributes];
    CGRect bounds = CGRectMake(0, 0, textSize.width, textSize.height);
    CGRect adjustedBounds = CGRectZero;
    if (self.textAlignment == NSTextAlignmentLeft) {
        adjustedBounds = CGRectMake(self.frame.origin.x, self.frame.origin.y, bounds.size.width, bounds.size.height);
    } else if (self.textAlignment == NSTextAlignmentCenter) {
        adjustedBounds = CGRectMake(self.frame.origin.x + (self.frame.size.width - bounds.size.width) / 2, self.frame.origin.y, bounds.size.width, bounds.size.height);
    } else if (self.textAlignment == NSTextAlignmentRight) {
        adjustedBounds = CGRectMake(self.frame.origin.x + self.frame.size.width - bounds.size.width, self.frame.origin.y, bounds.size.width, bounds.size.height);
    }
    return adjustedBounds;
}

@end
