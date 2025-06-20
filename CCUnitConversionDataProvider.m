#import "CCUnitConversionDataProvider.h"

@implementation CCUnitConversionDataProvider

+ (instancetype)sharedInstance {
    static CCUnitConversionDataProvider *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];

    if (self) {
        self.calculateFrameworkBundle = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/Calculate.framework"];
        if (!self.calculateFrameworkBundle) {
            NSLog(@"[UnitConversionDataProvider] Could not load Calculate framework bundle.");
            return nil;
        }
        [self.calculateFrameworkBundle load];

        NSString *path = [_calculateFrameworkBundle pathForResource:@"ConverterUnits" ofType:@"plist"];
        if (!path) {
            NSLog(@"[UnitConversionDataProvider] Could not find ConverterUnits.plist in bundle %@", _calculateFrameworkBundle.bundlePath);
            return nil;
        }
        NSDictionary *unitsDictionary = [NSDictionary dictionaryWithContentsOfFile:path];
        self.unitCollection = [[CalculateUnitCollection alloc] init];
        [self.unitCollection loadCategoriesFromDictionary:unitsDictionary];

        // Load default unit IDs from user defaults
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if (![defaults objectForKey:@"Converter.InputUnitID"]) {
            CalculateUnit *defaultInputUnit = [self.unitCollection unitForName:@"USD"];
            NSLog(@"[UnitConversionDataProvider] Default input unit: %@", defaultInputUnit);
            [defaults setInteger:defaultInputUnit.unitID forKey:@"Converter.InputUnitID"];
        }
        if (![defaults objectForKey:@"Converter.ResultUnitID"]) {
            CalculateUnit *defaultResultUnit = [self.unitCollection unitForName:@"EUR"];
            NSLog(@"[UnitConversionDataProvider] Default result unit: %@", defaultResultUnit);
            [defaults setInteger:defaultResultUnit.unitID forKey:@"Converter.ResultUnitID"];
        }
        if (![defaults objectForKey:@"Converter.CategoryID"]) {
            CalculateUnitCategory *defaultCategory = [self.unitCollection categoryForName:@"Currency"];
            NSLog(@"[UnitConversionDataProvider] Default category: %@", defaultCategory);
            [defaults setInteger:defaultCategory.categoryID forKey:@"Converter.CategoryID"];
        }

        CurrencyCache *currencyCache = [CurrencyCache shared];
        BOOL success = [currencyCache refresh];
        if (!success) {
            NSLog(@"[UnitConversionDataProvider] Failed to refresh currency cache.");
        } else {
            NSLog(@"[UnitConversionDataProvider] Currency cache refreshed successfully.");
        }
    }

    return self;
}

- (void)setInputUnitID:(NSUInteger)inputUnitID {
    [[NSUserDefaults standardUserDefaults] setInteger:inputUnitID forKey:@"Converter.InputUnitID"];
    [self _syncUnitsForChangedUnitID:inputUnitID isInput:YES];
}

- (void)setResultUnitID:(NSUInteger)resultUnitID {
    [[NSUserDefaults standardUserDefaults] setInteger:resultUnitID forKey:@"Converter.ResultUnitID"];
    [self _syncUnitsForChangedUnitID:resultUnitID isInput:NO];
}

- (void)setCategoryID:(NSUInteger)categoryID {
    [[NSUserDefaults standardUserDefaults] setInteger:categoryID forKey:@"Converter.CategoryID"];
}

- (NSUInteger)inputUnitID {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"Converter.InputUnitID"];
}

- (NSUInteger)resultUnitID {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"Converter.ResultUnitID"];
}

- (NSUInteger)categoryID {
    // TODO: ensure that the category ID matches the input unit's category 
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"Converter.CategoryID"];
}

- (CalculateUnitCategory *)categoryForID:(NSInteger)categoryID {
    return [self.unitCollection categoryForID:categoryID];
}

- (CalculateUnit *)unitForID:(NSInteger)unitID {
    for (CalculateUnitCategory *category in self.unitCollection.categories) {
        for (CalculateUnit *unit in category.units) {
            if (unit.unitID == unitID) {
                return unit;
            }
        }
    }
    return nil;
}

- (CalculateUnitCategory *)currencyCategory {
    for (CalculateUnitCategory *category in self.unitCollection.categories) {
        if (category.isCurrency) {
            return category;
        }
    }
    return nil;
}

- (void)_syncUnitsForChangedUnitID:(NSUInteger)unitID isInput:(BOOL)isInput {
    CalculateUnit *changedUnit = [self unitForID:unitID];
    if (!changedUnit) {
        NSLog(@"[UnitConversionDataProvider] Changed unit with ID %lu not found.", (unsigned long)unitID);
        return;
    }

    CalculateUnitCategory *category = changedUnit.category;
    if (!category) {
        NSLog(@"[UnitConversionDataProvider] Changed unit %@ does not have a valid category.", changedUnit);
        return;
    }


    NSString *otherKey = isInput ? @"Converter.ResultUnitID" : @"Converter.InputUnitID";
    NSLog(@"[UnitConversionDataProvider] Changed %@ unit to: %@", otherKey, changedUnit);
    NSUInteger otherUnitID = [[NSUserDefaults standardUserDefaults] integerForKey:otherKey];
    CalculateUnit *otherUnit = [self unitForID:otherUnitID];

    if (!otherUnit || otherUnit.category.categoryID != category.categoryID) {
        CalculateUnit *newOtherUnit = [self.unitCollection defaultUnitForCategory:category.categoryID excludingUnitID:unitID];
        if (newOtherUnit) {
            NSLog(@"[UnitConversionDataProvider] %@ -> %@", otherKey, newOtherUnit);
            if (isInput) {
                [self setResultUnitID:newOtherUnit.unitID];
            } else {
                [self setInputUnitID:newOtherUnit.unitID];
            }
        } else {
            NSLog(@"[UnitConversionDataProvider] ERROR: (%@) nothing found for category: %@", otherKey, category);
        }
    } else {
        NSLog(@"[UnitConversionDataProvider] %@ unit is still valid: %@", otherKey, otherUnit);
    }
}

@end