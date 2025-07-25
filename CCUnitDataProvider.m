#import "CCUnitDataProvider.h"
#import "Tweak.h"
#import <objc/runtime.h>

@implementation CCUnitDataProvider

+ (instancetype)sharedInstance {
    static CCUnitDataProvider *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];

    if (self) {
        _calculatorController = [(id)([UIApplication sharedApplication].delegate) getSwiftIvar:@"controller"];
        if (!_calculatorController) {
            NSLog(@"[CCUnitDataProvider] CalculatorController not found in app delegate.");
        }

        _calculatorModel = (CalculatorModel *)[_calculatorController getSwiftIvar:@"model"];
        if (!_calculatorModel) {
            NSLog(@"[CCUnitDataProvider] CalculatorModel not found in CalculatorController.");
        }

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

        _converter = [[Converter alloc] init];
        NSLog(@"[UnitConversionDataProvider] Converter initialized: %@", _converter);

        self.numberFormatter = [[objc_getClass("Calculator.CalculatorNumberFormatter") alloc] initWithMaximumDigitCount:15];

        _recentUnits = [NSMutableArray array];
        NSArray *recentUnitIDs = [defaults arrayForKey:@"Converter.RecentUnits"];
        for (NSNumber *unitID in recentUnitIDs) {
            CalculateUnit *unit = [self unitForID:unitID.integerValue];
            if (unit) {
                [_recentUnits addObject:unit];
            } else {
                NSLog(@"[UnitConversionDataProvider] Recent unit with ID %@ not found.", unitID);
            }
        }
    }

    return self;
}

- (DisplayValue *)convertDisplayValue:(DisplayValue *)value direction:(CCUnitConversionDirection)direction {
    if (!value) {
        NSLog(@"[UnitConversionDataProvider] ERROR nil parameter passed for value.");
        return nil;
    }

    CalculateUnit *inputUnit, *resultUnit;
    if (direction == CCUnitConversionDirectionInputToResult) {
        inputUnit = [self unitForID:[self inputUnitID]];
        resultUnit = [self unitForID:[self resultUnitID]];
    } else {
        inputUnit = [self unitForID:[self resultUnitID]];
        resultUnit = [self unitForID:[self inputUnitID]];
    }

    if (!inputUnit || !resultUnit) {
        NSLog(@"[UnitConversionDataProvider] ERROR invalid unit(s) for conversion: %@ -> %@", inputUnit, resultUnit);
        return nil;
    }

    NSNumber *inputValue = [self.numberFormatter numberFromString:[value valueString]];
    if (!inputUnit.category.isCurrency) {
        [_converter setConversionType:inputUnit.name];
        [_converter setInputValue:inputValue];
        [_converter setInputUnit:inputUnit.name];
        [_converter setOutputUnit:resultUnit.name];

        NSNumber *convertedValue = [_converter _operateConversionForOutputUnit:resultUnit.name];

        NSString *formattedValue = [self.numberFormatter stringFromNumber:convertedValue];
        return [[objc_getClass("Calculator.DisplayValue") alloc] initWithValue:formattedValue userEntered:NO];
    }

    NSDictionary *currencyData = [[CurrencyCache shared] currencyData];
    if (!currencyData) {
        NSLog(@"[UnitConversionDataProvider] No currency data available for conversion.");
        return nil;
    }

    NSLog(@"[UnitConversionDataProvider] Converting currency: %@ %@ -> %@", value, inputUnit.name, resultUnit.name);
    NSNumber *inputRate = currencyData[inputUnit.name];
    NSNumber *resultRate = currencyData[resultUnit.name];
    if (!inputRate || !resultRate) {
        NSLog(@"[UnitConversionDataProvider] failed to find rate(s) input = %@, result = %@", inputRate, resultRate);
        return nil;
    }

    NSDecimalNumber *inputAmount = [NSDecimalNumber decimalNumberWithDecimal:[inputValue decimalValue]];
    NSLog(@"[UnitConversionDataProvider] Input amount: %@", inputAmount);
    if ([inputAmount isEqualToNumber:[NSDecimalNumber notANumber]]) {
        NSLog(@"[UnitConversionDataProvider] ERROR input amount is NaN");
        return nil;
    }

    NSDecimalNumber *inputRateDecimal = [NSDecimalNumber decimalNumberWithDecimal:[inputRate decimalValue]];
    NSDecimalNumber *resultRateDecimal = [NSDecimalNumber decimalNumberWithDecimal:[resultRate decimalValue]];
    if ([inputRateDecimal isEqualToNumber:[NSDecimalNumber zero]]) {
        NSLog(@"[UnitConversionDataProvider] ERROR input rate is 0");
        return nil;
    }

    NSDecimalNumber *rateRatio = [resultRateDecimal decimalNumberByDividingBy:inputRateDecimal];
    NSDecimalNumber *converted = [inputAmount decimalNumberByMultiplyingBy:rateRatio];

    NSDecimalNumberHandler *roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                                                                                        scale:2
                                                                                             raiseOnExactness:NO
                                                                                              raiseOnOverflow:NO
                                                                                             raiseOnUnderflow:NO
                                                                                          raiseOnDivideByZero:YES];

    NSDecimalNumber *roundedConverted = [converted decimalNumberByRoundingAccordingToBehavior:roundingBehavior];

    NSString *formattedValue = [self.numberFormatter stringFromNumber:roundedConverted];
    return [[objc_getClass("Calculator.DisplayValue") alloc] initWithValue:formattedValue userEntered:NO];
}


- (void)setInputUnitID:(NSUInteger)inputUnitID {
    [self addRecentUnitID:inputUnitID];

    [[NSUserDefaults standardUserDefaults] setInteger:inputUnitID forKey:@"Converter.InputUnitID"];
    [self _syncUnitsForChangedUnitID:inputUnitID isInput:YES];
}

- (void)setResultUnitID:(NSUInteger)resultUnitID {
    [self addRecentUnitID:resultUnitID];

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
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"Converter.CategoryID"];
}

- (NSMutableArray<CalculateUnit *> *)recentUnits {
    if (_recentUnits) return _recentUnits;

    NSArray *recentUnitIDs = [[NSUserDefaults standardUserDefaults] arrayForKey:@"Converter.RecentUnits"];
    _recentUnits = [NSMutableArray array];
    for (NSNumber *unitID in recentUnitIDs) {
        CalculateUnit *unit = [self unitForID:unitID.integerValue];
        if (unit) {
            [_recentUnits addObject:unit];
        }
    }
    return _recentUnits;
}

- (void)addRecentUnitID:(NSUInteger)unitID {
    CalculateUnit *unit = [self unitForID:unitID];
    if (!unit) {
        NSLog(@"[UnitConversionDataProvider] Attempted to add a recent unit with ID %lu, but it was not found.", (unsigned long)unitID);
        return;
    }

    [self addRecentUnit:unit];
}

- (void)addRecentUnit:(CalculateUnit *)unit {
    if (!unit) {
        NSLog(@"[UnitConversionDataProvider] Attempted to add a nil unit to recent units.");
        return;
    }

    NSMutableArray *recentUnits = [self recentUnits];
    if ([recentUnits containsObject:unit]) {
        [recentUnits removeObject:unit];
    }
    [recentUnits insertObject:unit atIndex:0];

    if (recentUnits.count > 20) {
        [recentUnits removeLastObject];
    }

    [[NSUserDefaults standardUserDefaults] setObject:[recentUnits valueForKey:@"unitID"] forKey:@"Converter.RecentUnits"];
}

- (void)clearRecentUnits {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Converter.RecentUnits"];
    _recentUnits = [NSMutableArray array];
}

- (void)removeRecentUnitAtIndex:(NSUInteger)index {
    if (index >= self.recentUnits.count) {
        NSLog(@"[UnitConversionDataProvider] Attempted to remove recent unit at invalid index %lu.", (unsigned long)index);
        return;
    }

    NSMutableArray *recentUnits = [self recentUnits];
    [recentUnits removeObjectAtIndex:index];
    [[NSUserDefaults standardUserDefaults] setObject:[recentUnits valueForKey:@"unitID"] forKey:@"Converter.RecentUnits"];
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