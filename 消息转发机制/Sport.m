//
//  Sport.m
//  消息转发机制
//
//  Created by 闫跃文 on 2018/3/15.
//  Copyright © 2018年 闫跃文. All rights reserved.
//

#import "Sport.h"

@implementation Sport



- (void)eat {
    
    NSLog(@"跑步");
}

/**
 设置键值是否观察

 @param key 需要设置的参数
 @return 是否观察
 */
/* Return YES if the key-value observing machinery should automatically invoke -willChangeValueForKey:/-didChangeValueForKey:, -willChange:valuesAtIndexes:forKey:/-didChange:valuesAtIndexes:forKey:, or -willChangeValueForKey:withSetMutation:usingObjects:/-didChangeValueForKey:withSetMutation:usingObjects: whenever instances of the class receive key-value coding messages for the key, or mutating key-value coding-compliant methods for the key are invoked. Return NO otherwise. Starting in Mac OS 10.5, the default implementation of this method searches the receiving class for a method whose name matches the pattern +automaticallyNotifiesObserversOf<Key>, and returns the result of invoking that method if it is found. So, any such method must return BOOL too. If no such method is found YES is returned.
 */
//+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
//
//    if ([key isEqualToString:@"time"]) {
//        // 通过此方法设置这个参数不可观察
//        return NO;
//    }
//
//    return YES;
//}

//
//- (void)setTime:(NSInteger)time {
//
//    // 通过此方法设置这个参数可观察
//    [self willChangeValueForKey:@"time"];
//
//    _time = time;
//
//    [self didChangeValueForKey:@"time"];
//}



@end
