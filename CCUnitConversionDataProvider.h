#import <Foundation/Foundation.h>
#import <Calculate/Converter.h>
#import "CalculateUnits/CalculateUnitCollection.h"

@interface CCUnitConversionDataProvider : NSObject {
    Converter *_converter;
}
@property (nonatomic, strong) CalculateUnitCollection *unitCollection;
@property (nonatomic, strong) NSBundle *calculateFrameworkBundle;
@property (nonatomic, assign) NSUInteger inputUnitID;
@property (nonatomic, assign) NSUInteger resultUnitID;
@property (nonatomic, assign) NSUInteger categoryID;

+ (instancetype)sharedInstance;
- (CalculateUnitCategory *)categoryForID:(NSInteger)categoryID;
- (CalculateUnitCategory *)currencyCategory;
@end