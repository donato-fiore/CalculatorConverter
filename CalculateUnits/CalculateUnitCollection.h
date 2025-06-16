#import <Foundation/Foundation.h>

#import "CalculateUnitCategory.h"

@interface CalculateUnitCollection : NSObject
@property (nonatomic, strong) NSMutableArray<CalculateUnitCategory *> *categories;
@property (nonatomic, readonly) NSBundle *calculateFrameworkBundle;
+ (instancetype)sharedCollection;
@end