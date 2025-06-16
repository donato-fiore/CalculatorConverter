#import <Foundation/Foundation.h>

#import "CalculateUnitCategory.h"

@interface CalculateUnit : NSObject {
    NSString *_shortName;
}

@property (nonatomic, readonly) NSString *shortName;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger unitID;
@property (nonatomic, strong) CalculateUnitCategory *category;

- (instancetype)initWithName:(NSString *)name unitInfo:(NSDictionary *)unitInfo;

@end