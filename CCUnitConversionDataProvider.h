#import <Foundation/Foundation.h>
#import <Calculate/Converter.h>
#import "CalculateUnits/CalculateUnitCollection.h"

@interface CCUnitConversionDataProvider : NSObject {
    Converter *_converter;
}
@property (nonatomic, strong) CalculateUnitCollection *unitCollection;
@property (nonatomic, strong) NSBundle *calculateFrameworkBundle;
@property (nonatomic, assign) NSInteger inputUnitID;
@property (nonatomic, assign) NSInteger resultUnitID;
+ (instancetype)sharedInstance;
@end