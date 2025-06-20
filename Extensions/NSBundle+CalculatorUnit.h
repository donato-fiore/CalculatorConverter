#import <Foundation/Foundation.h>

@interface NSBundle (CalculatorUnit)

/**
 * Returns the main bundle for the CalculatorUnit framework.
 *
 * @return The main bundle for the CalculatorUnit framework.
 */

- (NSString *)calc_localizedStringForKey:(NSString *)key 
                               value:(NSString *)value 
                               table:(NSString *)tableName;

@end