#import "UIImage+CalculatorUnitConversion.h"

@implementation UIImage (CalculatorUnitConversion)

+ (UIImage *)calc_systemImageNamed:(NSString *)name {
    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIImageSymbolWeightMedium scale:UIImageSymbolScaleMedium];
    return [UIImage systemImageNamed:name withConfiguration:config];
}

@end