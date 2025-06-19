#ifndef CURRENCYCACHE_H
#define CURRENCYCACHE_H

#import <Foundation/Foundation.h>

@class NSMutableDictionary, NSString, NSDictionary, NSMutableString, NSDate, NSObject, NSNumber;
@protocol OS_dispatch_queue;

@interface CurrencyCache : NSObject <NSXMLParserDelegate> {
    NSDate *_lastRefreshDate;
    NSString *_currentCurrency;
    NSNumber *_currentRate;
    NSMutableString *_currentString;
    NSMutableDictionary *_mutableCurrencyCache;
}

@property (retain, nonatomic) NSObject<OS_dispatch_queue> *serializer;
@property (readonly) unsigned long long uuid;
@property (readonly, nonatomic) NSDate *lastRefreshDate;
@property (retain, nonatomic) NSDictionary *currencyData;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

+ (id)shared;

- (BOOL)refresh;
- (id)_consumerKey;
- (id)init;
- (id)createCredential;
- (void)_loadPersistedCurrencyCache;
- (void)_queue_persistCurrencyCache;
- (void)_queue_loadPersistedCurrencyCache;
- (BOOL)_queue_refresh;
- (BOOL)refreshWithTimeOut:(float)a0;
- (BOOL)updateCurrencyCacheWithData:(id)a0;
- (id)_consumerSecret;

@end

#endif // CURRENCYCACHE_H