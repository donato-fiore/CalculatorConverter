#import "CalculateUnit.h"
#import "CalculateUnitCollection.h"

@implementation CalculateUnit
@synthesize name = _name;

- (instancetype)initWithName:(NSString *)name unitInfo:(NSDictionary *)unitInfo {
    self = [super init];
    if (self) {
        _name = name;
        _unitID = -1;
    }
    return self;
}

- (NSString *)shortName {
    if (!_shortName) {
        NSBundle *bundle = [CalculateUnitCollection sharedCollection].calculateFrameworkBundle;
        NSString *loc = [bundle localizedStringForKey:_name value:nil table:@"LocalizableUnits"];
        NSLog(@"[CalculateUnit] localized string for %@: %@", _name, loc);
        _shortName = loc;
    }

    // if (!_shortName) {
    //     _shortName = _name;
    // }

    return _shortName;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, name: %@, unitID: %ld>", 
            NSStringFromClass([self class]),
            self,
            [self shortName],
            (long)_unitID];
}

@end