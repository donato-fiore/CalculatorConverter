#import <Foundation/Foundation.h>
#import <Calculate/Converter.h>
#import <Calculate/CurrencyCache.h>
#import "CalculateUnits/CalculateUnits.h"

@class CalculatorNumberFormatter, DisplayValue, CalculatorModel, CalculatorController;

typedef NS_ENUM(bool, CCUnitConversionDirection) {
    CCUnitConversionDirectionInputToResult = YES,
    CCUnitConversionDirectionResultToInput = NO
};

@interface CCUnitDataProvider : NSObject {
    Converter *_converter;
    CalculatorModel *_calculatorModel;
    CalculatorController *_calculatorController;
}
@property (nonatomic, strong) CalculatorNumberFormatter *numberFormatter;
@property (nonatomic, strong) CalculateUnitCollection *unitCollection;
@property (nonatomic, strong) NSBundle *calculateFrameworkBundle;
@property (nonatomic, strong) NSMutableArray<CalculateUnit *> *recentUnits;
@property (nonatomic, assign) NSUInteger inputUnitID;
@property (nonatomic, assign) NSUInteger resultUnitID;
@property (nonatomic, assign) NSUInteger categoryID;
@property (nonatomic, readonly) CalculatorModel *calculatorModel;
@property (nonatomic, readonly) CalculatorController *calculatorController;

+ (instancetype)sharedInstance;
- (void)addRecentUnit:(CalculateUnit *)unit;
- (void)clearRecentUnits;
- (void)removeRecentUnitAtIndex:(NSUInteger)index;
- (DisplayValue *)convertDisplayValue:(DisplayValue *)value direction:(CCUnitConversionDirection)direction;
- (CalculateUnitCategory *)categoryForID:(NSInteger)categoryID;
- (CalculateUnitCategory *)currencyCategory;
- (CalculateUnit *)unitForID:(NSInteger)unitID;
@end