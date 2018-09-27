

#import <Foundation/Foundation.h>

@interface NSTimer (XJWeakTimer)
+ (NSTimer *)xj_scheduledTimerWithTimeInterval:(NSTimeInterval)timeInterval
                                       repeats:(BOOL)repeats
                                  handlerBlock:(void(^)(void))handler;
@end
