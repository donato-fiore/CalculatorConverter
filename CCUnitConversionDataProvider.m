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
    }

    return self;
}

@end