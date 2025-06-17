#import <Foundation/Foundation.h>

#import "CalculateUnits.h"

@interface CalculateUnitCollection : NSObject {
    NSMutableArray<CalculateUnitCategory *> *_categories;
}
@property (nonatomic, strong) NSMutableArray<CalculateUnitCategory *> *categories;
- (void)loadCategoriesFromDictionary:(NSDictionary *)dictionary;
- (CalculateUnitCategory *)categoryForID:(NSInteger)categoryID;
- (CalculateUnit *)unitForName:(NSString *)name;
- (CalculateUnitCategory *)categoryForName:(NSString *)name;
@end