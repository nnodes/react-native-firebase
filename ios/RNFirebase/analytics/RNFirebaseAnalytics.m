#import "RNFirebaseAnalytics.h"
#import <React/RCTUtils.h>

#if __has_include(<FirebaseAnalytics/FIRAnalytics.h>)
#import <FirebaseAnalytics/FIRAnalytics.h>

@implementation RNFirebaseAnalytics
RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(logEvent:(NSString *)name params:(NSDictionary *)params) {
  [FIRAnalytics logEventWithName:name parameters:[self cleanJavascriptParams:params]];
}

RCT_EXPORT_METHOD(setAnalyticsCollectionEnabled:(BOOL) enabled) {
  [FIRAnalytics setAnalyticsCollectionEnabled:enabled];
}

RCT_EXPORT_METHOD(setCurrentScreen:(NSString *) screenName screenClass:(NSString *) screenClassOverriew) {
  RCTUnsafeExecuteOnMainQueueSync(^{
    [FIRAnalytics setScreenName:screenName screenClass:screenClassOverriew];
  });
}

RCT_EXPORT_METHOD(setUserId: (NSString *) id) {
  [FIRAnalytics setUserID:id];
}

RCT_EXPORT_METHOD(setUserProperty: (NSString *) name value:(NSString *) value) {
  [FIRAnalytics setUserPropertyString:value forName:name];
}

// not implemented on iOS sdk
RCT_EXPORT_METHOD(setMinimumSessionDuration:(nonnull NSNumber *) milliseconds) {}
RCT_EXPORT_METHOD(setSessionTimeoutDuration:(nonnull NSNumber *) milliseconds) {}

#pragma mark -
#pragma mark Private methods

  - (NSDictionary *)cleanJavascriptParams:(NSDictionary *)params {
    NSMutableDictionary *newParams = [params mutableCopy];
    if (newParams[kFIRParameterItems]) {
      NSMutableArray *newItems = [NSMutableArray array];
      [(NSArray *)newParams[kFIRParameterItems] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *item = [obj mutableCopy];
        if (item[kFIRParameterQuantity]) {
          NSOperatingSystemVersion ios15 = (NSOperatingSystemVersion){15, 0, 0};
          if (![[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:ios15]) {
              item[kFIRParameterQuantity] = @([item[kFIRParameterQuantity] doubleValue]);
              item[kFIRParameterPrice] = @([item[kFIRParameterPrice] doubleValue]);
          }

          item[kFIRParameterQuantity] = @([item[kFIRParameterQuantity] integerValue]);
        }
        [newItems addObject:[item copy]];
      }];
      newParams[kFIRParameterItems] = [newItems copy];
    }
    return [newParams copy];
  }

@end

#else
@implementation RNFirebaseAnalytics
@end
#endif
