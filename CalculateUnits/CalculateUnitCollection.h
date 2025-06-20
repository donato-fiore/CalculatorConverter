#import <Foundation/Foundation.h>

#import "CalculateUnits.h"

@interface CalculateUnitCollection : NSObject {
    NSMutableArray<CalculateUnitCategory *> *_categories;
}
@property (nonatomic, strong) NSMutableArray<CalculateUnitCategory *> *categories;
- (void)loadCategoriesFromDictionary:(NSDictionary *)dictionary;
- (CalculateUnit *)unitForName:(NSString *)name;
- (CalculateUnitCategory *)categoryForName:(NSString *)name;
- (CalculateUnitCategory *)categoryForID:(NSInteger)categoryID;

- (CalculateUnit *)defaultUnitForCategory:(NSInteger)categoryID excludingUnitID:(NSInteger)excludedUnitID;

@end