#import "CalculateUnitCategory.h"
#import "CalculateUnit.h"

@implementation CalculateUnitCategory

- (instancetype)initWithName:(NSString *)name categoryInfo:(NSDictionary *)categoryInfo {
    self = [super init];
    if (self) {
        _name = name;
        if ([name isEqualToString:@"Currency"]) _isCurrency = YES;
        
        _units = [NSMutableArray array];

        [categoryInfo enumerateKeysAndObjectsUsingBlock:^(NSString *unitName, NSDictionary *unitInfo, BOOL *stop) {
            if ([unitName isEqualToString:@"BaseDecomposition"]) return; // Skip BaseDecomposition unit

            CalculateUnit *unit = [[CalculateUnit alloc] initWithName:unitName unitInfo:unitInfo];
            unit.category = self;
            [_units addObject:unit];
        }];
    }
    return self;
}

- (instancetype)filteredUnitsMatchingString:(NSString *)searchString {
    if (searchString.length == 0) return self;

    NSMutableArray *filteredUnits = [NSMutableArray array];
    for (CalculateUnit *unit in _units) {
        if ([unit.displayName rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound ||
            [unit.shortName rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound ||
            [unit.name rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [filteredUnits addObject:unit];
        }
    }

    CalculateUnitCategory *filteredCategory = [[CalculateUnitCategory alloc] initWithName:_name categoryInfo:@{}];
    filteredCategory.units = filteredUnits;
    filteredCategory.isCurrency = _isCurrency;

    return filteredCategory;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, name: %@, units.count: %lu>", 
            NSStringFromClass([self class]),
            self,
            _name,
            (unsigned long)_units.count];
}

@end