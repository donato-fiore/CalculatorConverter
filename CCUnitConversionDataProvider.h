#import <Foundation/Foundation.h>
#import <Calculate/Converter.h>
#import <Calculate/CurrencyCache.h>
#import "CalculateUnits/CalculateUnits.h"

@interface CCUnitConversionDataProvider : NSObject {
    Converter *_converter;
}
@property (nonatomic, strong) CalculateUnitCollection *unitCollection;
@property (nonatomic, strong) NSBundle *calculateFrameworkBundle;
@property (nonatomic, strong) NSMutableArray<CalculateUnit *> *recentUnits;
@property (nonatomic, assign) NSUInteger inputUnitID;
@property (nonatomic, assign) NSUInteger resultUnitID;
@property (nonatomic, assign) NSUInteger categoryID;

+ (instancetype)sharedInstance;
- (void)addRecentUnit:(CalculateUnit *)unit;
- (void)clearRecentUnits;
- (NSNumber *)convertValue:(NSNumber *)value;
- (CalculateUnitCategory *)categoryForID:(NSInteger)categoryID;
- (CalculateUnitCategory *)currencyCategory;
- (CalculateUnit *)unitForID:(NSInteger)unitID;
@end