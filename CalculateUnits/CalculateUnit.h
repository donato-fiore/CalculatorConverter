#import <Foundation/Foundation.h>

@class CalculateUnitCategory;

@interface CalculateUnit : NSObject {
    NSString *_displayName;
    NSString *_shortName;
}

@property (nonatomic, strong) CalculateUnitCategory *category;
@property (nonatomic, readonly) NSString *displayName;
@property (nonatomic, readonly) NSString *shortName;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger unitID;

- (instancetype)initWithName:(NSString *)name unitInfo:(NSDictionary *)unitInfo;

@end