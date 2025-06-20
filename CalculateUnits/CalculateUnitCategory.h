#import <Foundation/Foundation.h>
#import "CalculateUnit.h"

@interface CalculateUnitCategory : NSObject
@property (nonatomic, assign) NSInteger categoryID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray *units;
@property (nonatomic, assign) BOOL isCurrency;

- (instancetype)initWithName:(NSString *)name categoryInfo:(NSDictionary *)categoryInfo;
- (instancetype)filteredUnitsMatchingString:(NSString *)searchString;

@end