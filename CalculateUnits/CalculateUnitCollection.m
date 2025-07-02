#import "CalculateUnitCollection.h"
#import "CalculateUnit.h"
#import "CCUnitDataProvider.h"

@implementation CalculateUnitCollection

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _categories = [NSMutableArray array];
    }

    return self;
}

- (void)loadCategoriesFromDictionary:(NSDictionary *)dictionary {
    __block NSInteger unitID = 0;
    __block NSInteger categoryID = 0;
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *categoryName, NSDictionary *categoryInfo, BOOL *stop) {
        CalculateUnitCategory *category = [[CalculateUnitCategory alloc] initWithName:categoryName categoryInfo:categoryInfo];
        category.categoryID = categoryID++;
        
        [category.units enumerateObjectsUsingBlock:^(CalculateUnit *unit, NSUInteger idx, BOOL *stop) {
            unit.unitID = unitID++;
        }];

        [category.units sortUsingComparator:^NSComparisonResult(CalculateUnit *unit1, CalculateUnit *unit2) {
            return [unit1.displayName compare:unit2.displayName];
        }];

        [_categories addObject:category];
    }];

    [_categories sortUsingComparator:^NSComparisonResult(CalculateUnitCategory *category1, CalculateUnitCategory *category2) {
        return [category1.name compare:category2.name];
    }];
}

- (CalculateUnitCategory *)categoryForID:(NSInteger)categoryID {
    for (CalculateUnitCategory *category in _categories) {
        if (category.categoryID == categoryID) {
            return category;
        }
    }
    return nil;
}

- (CalculateUnitCategory *)categoryForName:(NSString *)name {
    for (CalculateUnitCategory *category in _categories) {
        if ([category.name isEqualToString:name]) {
            return category;
        }
    }
    return nil;
}

- (CalculateUnit *)unitForName:(NSString *)name {
    for (CalculateUnitCategory *category in _categories) {
        for (CalculateUnit *unit in category.units) {
            if ([unit.name isEqualToString:name]) {
                return unit;
            }
        }
    }
    return nil;
}

- (CalculateUnit *)defaultUnitForCategory:(NSInteger)categoryID excludingUnitID:(NSInteger)excludedUnitID {
    CalculateUnitCategory *category = [self categoryForID:categoryID];
    if (!category) return nil;
    
    NSArray *recentUnits = [CCUnitDataProvider sharedInstance].recentUnits;
    for (CalculateUnit *unit in recentUnits) {
        if (unit.unitID != excludedUnitID && unit.category.categoryID == categoryID) {
            NSLog(@"[CalculateUnitCollection] Found recent unit: %@", unit.displayName);
            return unit;
        }
    }

    for (CalculateUnit *unit in category.units) {
        if (unit.unitID != excludedUnitID) {
            NSLog(@"[CalculateUnitCollection] Found default unit: %@", unit.displayName);
            return unit;
        }
    }

    NSLog(@"[CalculateUnitCollection] No unit found for category: %@", category.name);
    return nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, categories.count: %lu>", 
            NSStringFromClass([self class]), 
            self, 
            (unsigned long)_categories.count];
}

@end