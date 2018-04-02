//
//  NSObject+YYKVO.h
//  消息转发机制
//
//  Created by 闫跃文 on 2018/3/26.
//  Copyright © 2018年 闫跃文. All rights reserved.
//  class_getInstanceMethod 获取不到不知为啥

#import <Foundation/Foundation.h>

typedef void(^YYKVOBlock)(id observer, NSString *keyPath, id newValue, id oldValue);

@interface NSObject (YYKVO)

- (void)yy_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath block:(YYKVOBlock)block;

@end
