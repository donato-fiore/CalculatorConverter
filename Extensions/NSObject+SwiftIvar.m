#import "NSObject+SwiftIvar.h"
#import <objc/runtime.h>

@implementation NSObject (SwiftIvar)

- (instancetype)getSwiftIvar:(NSString *)ivarName {
    Ivar ivar = class_getInstanceVariable([self class], ivarName.UTF8String);
	if (!ivar) {
		return nil;
	}
	return object_getIvar(self, ivar);
}

@end