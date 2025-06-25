#import "UILabel+EffectiveTextBounds.h"

@implementation UILabel (EffectiveTextBounds)

- (CGRect)effectiveTextBounds {
    NSString *text = self.text;
    if (text.length == 0) return CGRectZero;

    NSDictionary *attributes = @{ NSFontAttributeName: self.font };
    CGSize textSize = [text sizeWithAttributes:attributes];
    CGRect bounds = self.bounds;
    
    CGFloat originX = 0;
    switch (self.textAlignment) {
        case NSTextAlignmentCenter:
            originX = (bounds.size.width - textSize.width) / 2;
            break;
        case NSTextAlignmentRight:
            originX = bounds.size.width - textSize.width;
            break;
        case NSTextAlignmentLeft:
        default:
            originX = 0;
            break;
    }

    return CGRectMake(originX, (bounds.size.height - textSize.height) / 2, textSize.width, textSize.height);
}

@end
