#ifndef CONVERTER_H
#define CONVERTER_H

@class NSArray, NSString, NSNumber;

#import <Foundation/Foundation.h>

@interface Converter : NSObject

@property (retain, nonatomic) NSArray *additionalResults; // ivar: _additionalResults
@property (retain, nonatomic) NSString *conversionType; // ivar: _conversionType
@property float currencyUpdateTimeOut; // ivar: _currencyUpdateTimeOut
@property (retain, nonatomic) NSString *inputString; // ivar: _inputString
@property (retain, nonatomic) NSString *inputUnit; // ivar: _inputUnit
@property (retain, nonatomic) NSNumber *inputValue; // ivar: _inputValue
@property (readonly) BOOL isCurrency; // ivar: _isCurrency
@property (retain, nonatomic) NSString *localizedInputValueAndUnit; // ivar: _localizedInputValueAndUnit
@property (retain, nonatomic) NSString *localizedOutputUnit; // ivar: _localizedOutputUnit
@property (retain, nonatomic) NSString *localizedOutputValue; // ivar: _localizedOutputValue
@property (retain, nonatomic) NSString *localizedOutputValueAndUnit; // ivar: _localizedOutputValueAndUnit
@property (retain, nonatomic) NSString *outputUnit; // ivar: _outputUnit
@property (retain, nonatomic) NSNumber *outputValue; // ivar: _outputValue


+(BOOL)refreshCurrencyCache;
+(id)currencyCacheLastRefreshDate;
+(id)dispatchQueue;
+(void)initialize;
-(BOOL)_parseInputQuery;
-(CGFloat)_doubleWithoutUnrelevantDecimalsForNumber:(id)arg0 ;
-(id)_localizedPluralizedStringsforNumber:(id)arg0 unit:(id)arg1 ;
-(id)_normalizedUnitNamesForName:(id)arg0 ;
-(NSNumber *)_operateConversionForOutputUnit:(id)arg0 ;
-(id)_safe_subStringOf:(id)arg0 withRange:(struct _NSRange )arg1 ;
-(id)_unitInfoForNormalizedName:(id)arg0 ;
-(id)initWithInput:(id)arg0 ;
-(id)similarUnitsForNormalizedName:(id)arg0 ;
-(void)_performUnitPluralization;
-(void)_standardizeInputAndOutputUnits;
-(void)_updateInputValueFromMatch:(id)arg0 ;
-(void)processConversionWithCompletion:(id)arg0 ;


@end


#endif