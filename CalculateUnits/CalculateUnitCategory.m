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

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, name: %@, units.count: %lu>", 
            NSStringFromClass([self class]),
            self,
            _name,
            (unsigned long)_units.count];
}

@end