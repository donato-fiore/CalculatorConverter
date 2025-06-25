#import <Foundation/Foundation.h>

@interface NSBundle (CalculatorUnit)

/**
 * Returns the main bundle for the CalculatorUnit framework.
 *
 * @return The main bundle for the CalculatorUnit framework.
 */
+ (NSBundle *)calculator_mainBundle;

/**
 * Returns a localized string for the specified key, value, and table.
 *
 * @param key The key for the string to be localized.
 * @param value The value to return if the key is not found.
 * @param tableName The name of the table containing the localized strings.
 * @return A localized string for the specified key, value, and table.
 */
- (NSString *)calc_localizedStringForKey:(NSString *)key 
                               value:(NSString *)value 
                               table:(NSString *)tableName;

@end