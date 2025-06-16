#import "CalculateUnitCollection.h"
#import "CalculateUnit.h"

@implementation CalculateUnitCollection

+ (instancetype)sharedCollection {
    static CalculateUnitCollection *sharedCollection = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle *bundle = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/Calculate.framework"];
        [bundle load];

        sharedCollection = [[self alloc] initWithBundle:bundle];
    });

    return sharedCollection;
}

- (instancetype)initWithBundle:(NSBundle *)bundle {
    self = [super init];
    
    if (self) {
        _categories = [NSMutableArray array];
        _calculateFrameworkBundle = bundle;

        [self loadCategories];
    }

    return self;
}

- (void)loadCategories {
    NSString *path = [_calculateFrameworkBundle pathForResource:@"ConverterUnits" ofType:@"plist"];
    if (!path) {
        NSLog(@"Error: Could not find ConverterUnits.plist in bundle %@", _calculateFrameworkBundle.bundlePath);
        return;
    }

    __block NSInteger unitID = 0;
    __block NSInteger categoryID = 0;
    NSDictionary *unitsDictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    [unitsDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *categoryName, NSDictionary *categoryInfo, BOOL *stop) {
        CalculateUnitCategory *category = [[CalculateUnitCategory alloc] initWithName:categoryName categoryInfo:categoryInfo];
        category.categoryID = categoryID++;

        // NSLog(@"[CalculateUnitCollection] categoryName: %@", categoryName);
        // NSLog(@"[CalculateUnitCollection] categoryInfo: %@", categoryInfo);
        
        [category.units enumerateObjectsUsingBlock:^(CalculateUnit *unit, NSUInteger idx, BOOL *stop) {
            unit.unitID = unitID++;
        }];

        [_categories addObject:category];
    }];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, categories.count: %lu>", 
            NSStringFromClass([self class]), 
            self, 
            (unsigned long)_categories.count];
}

@end