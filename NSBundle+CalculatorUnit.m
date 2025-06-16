#import <Foundation/Foundation.h>
#import <rootless.h>

@implementation NSBundle (CalculatorUnit)

- (NSString *)calc_localizedStringForKey:(NSString *)key
                                   value:(NSString *)value
                                   table:(NSString *)tableName {

    if ([[self localizedStringForKey:key value:@"." table:tableName] length] == 1) {
        NSBundle *fallbackBundle = [NSBundle bundleWithPath:ROOT_PATH_NS(@"/Library/Tweak Support/CalculateUnits")];
        // NSLog(@"[NSBundle+CalculatorUnit] Fallback to bundle: %@", fallbackBundle.bundlePath);
        return [fallbackBundle localizedStringForKey:key value:value table:tableName];
    }
    NSString *localizedString = [self localizedStringForKey:key value:@"." table:tableName];
    NSLog(@"[NSBundle+CalculatorUnit] Localized string for key '%@': %@", key, localizedString);

    return localizedString;
}

@end