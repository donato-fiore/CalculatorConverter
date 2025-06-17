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
    }

    return self;
}

#pragma mark - Custom Setters

- (void)setInputUnitID:(NSUInteger)inputUnitID {
    [[NSUserDefaults standardUserDefaults] setInteger:inputUnitID forKey:@"Converter.InputUnitID"];
}

- (void)setResultUnitID:(NSUInteger)resultUnitID {
    [[NSUserDefaults standardUserDefaults] setInteger:resultUnitID forKey:@"Converter.ResultUnitID"];
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

#pragma mark - Convenience Methods

- (CalculateUnitCategory *)categoryForID:(NSInteger)categoryID {
    return [self.unitCollection categoryForID:categoryID];
}

- (CalculateUnitCategory *)currencyCategory {
    for (CalculateUnitCategory *category in self.unitCollection.categories) {
        if (category.isCurrency) {
            return category;
        }
    }
    return nil;
}

@end