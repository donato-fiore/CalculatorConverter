#import <Foundation/Foundation.h>

#import "CalculateUnitCategory.h"

@interface CalculateUnitCollection : NSObject
@property (nonatomic, strong) NSMutableArray<CalculateUnitCategory *> *categories;
- (void)loadCategoriesFromDictionary:(NSDictionary *)dictionary;
@end