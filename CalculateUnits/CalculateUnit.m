#import "CalculateUnit.h"
#import "CalculateUnitCollection.h"
#import "../NSBundle+CalculatorUnit.h"

@implementation CalculateUnit
@synthesize displayName = _displayName;
@synthesize shortName = _shortName;

- (instancetype)initWithName:(NSString *)name unitInfo:(NSDictionary *)unitInfo {
    self = [super init];
    if (self) {
        _name = name;
        _unitID = -1;
    }
    return self;
}

- (NSString *)displayName {
    if (!_displayName) {
        if (self.category.isCurrency) {
            NSLocale *locale = [NSLocale currentLocale];
            _displayName = [locale displayNameForKey:NSLocaleCurrencyCode value:_name];
        } else {
            NSString *title = [_name stringByAppendingString:@" (Title)"];
            _displayName = [[NSBundle mainBundle] calc_localizedStringForKey:title value:@"Error" table:@"LocalizableUnits"];
        }
    }

    return _displayName;
}

- (NSString *)shortName {
    if (!_shortName) {
        NSString *title = [_name stringByAppendingString:@" (Short)"];
        _shortName = [[NSBundle mainBundle] calc_localizedStringForKey:title value:@"Error" table:@"LocalizableUnits"];
    }

    return _shortName;
}



- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, %@ (%@), unitID: %ld>", 
            NSStringFromClass([self class]),
            self,
            [self shortName],
            [self displayName],
            (long)_unitID];
}

@end