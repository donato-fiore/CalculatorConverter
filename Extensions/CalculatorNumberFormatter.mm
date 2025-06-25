#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <substrate.h>
#import "NSBundle+CalculatorUnit.h"

NSObject *bridgedInit(id self, SEL _cmd, NSInteger maximumDigitCount) {
    struct objc_super superInfo = { self, [NSNumberFormatter class] };
    NSNumberFormatter *instance = ((id (*)(struct objc_super *, SEL))objc_msgSendSuper)(&superInfo, @selector(init));
    if (!instance) return nil;

    MSHookIvar<NSInteger>(instance, "maximumDigitCount") = maximumDigitCount;
    MSHookIvar<BOOL>(instance, "allowScientific") = YES;

    instance.numberStyle = NSNumberFormatterDecimalStyle;
    NSBundle *bundle = [NSBundle calculator_mainBundle];
    NSString *localeError = [bundle localizedStringForKey:@"Error" value:@"Error" table:nil];

    instance.notANumberSymbol = localeError;
    instance.nilSymbol = localeError;
    instance.exponentSymbol = @"e";

    return instance;
}

__attribute__((constructor)) static void init_CalculatorNumberFormatter() {
    class_addMethod(objc_getClass("Calculator.CalculatorNumberFormatter"), 
                    sel_getUid("initWithMaximumDigitCount:"),
                    (IMP)bridgedInit,
                    "@@:i");
}