#import <UIKit/UIKit.h>

@interface UIImage (CalculatorUnitConversion)

/**
 * Returns a system image with the specified name and applies a configuration.
 * If the image is not found, it returns nil.
 *
 * @param name The name of the system image.
 * @return The system image or nil if not found.
 */
+ (UIImage *)calc_systemImageNamed:(NSString *)name;

@end