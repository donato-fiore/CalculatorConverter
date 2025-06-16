#import <Foundation/Foundation.h>
#import <Calculate/Converter.h>

@interface CCUnitConversionDataProvider : NSObject {
    Converter *_converter;
}
@property (nonatomic, assign) NSInteger inputUnitID;
@property (nonatomic, assign) NSInteger resultUnitID;
@end