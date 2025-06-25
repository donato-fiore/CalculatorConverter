#import <Foundation/Foundation.h>
#import <rootless.h>
#import <objc/runtime.h>

@implementation NSBundle (CalculatorUnit)

+ (NSBundle *)calculator_mainBundle {
    static NSBundle *mainBundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mainBundle = [NSBundle bundleForClass:objc_getClass("Calculator.CalculatorController")];
    });
    return mainBundle;
}

- (NSString *)calc_localizedStringForKey:(NSString *)key
                                   value:(NSString *)value
                                   table:(NSString *)tableName {

    static NSBundle *fallbackBundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fallbackBundle = [NSBundle bundleWithPath:ROOT_PATH_NS(@"/Library/Tweak Support/CalculateUnits.bundle")];
    });

    NSString *localizedString = [self localizedStringForKey:key value:@"." table:tableName];
    
    if ([localizedString length] == 1) {
        return [fallbackBundle localizedStringForKey:key value:value table:tableName];
    }
    
    return localizedString;
}

@end
