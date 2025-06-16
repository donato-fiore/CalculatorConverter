#import <Foundation/Foundation.h>

@interface CalculateUnitCategory : NSObject {
    /*
    some form of id mapping
    */
    NSDictionary *_categoryInfo;
}

@property (nonatomic, assign) NSInteger categoryID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray *units;
@property (nonatomic, assign) BOOL isCurrency;

- (instancetype)initWithName:(NSString *)name categoryInfo:(NSDictionary *)categoryInfo;

@end