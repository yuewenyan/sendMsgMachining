//
//  Person.m
//  消息转发机制
//
//  Created by 闫跃文 on 2018/3/15.
//  Copyright © 2018年 闫跃文. All rights reserved.
//

#import "Person.h"
#import "Sport.h"
#import <objc/runtime.h>

/*
// 快速消息转发
- (id)forwardingTargetForSelector:(SEL)aSelector OBJC_AVAILABLE(10.5, 2.0, 9.0, 1.0, 2.0);
// 标准消息转发
 - (void)forwardInvocation:(NSInvocation *)anInvocation OBJC_SWIFT_UNAVAILABLE("");
 - (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector OBJC_SWIFT_UNAVAILABLE("");
// 动态方法解析（一个是类的一个是对象的）
+ (BOOL)resolveClassMethod:(SEL)sel OBJC_AVAILABLE(10.5, 2.0, 9.0, 1.0, 2.0);
+ (BOOL)resolveInstanceMethod:(SEL)sel OBJC_AVAILABLE(10.5, 2.0, 9.0, 1.0, 2.0);
 */


@implementation Person

/**
 1.重写父类的动态方法解析 - 此处测试用的对象方法 （类方法为 + (BOOL)resolveClassMethod:(SEL)sel 可以自己试）
 */
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    
//    判断是否实现， 动态添加  ----  想要运行2.快速消息转发，消息转发重定向 需注释此处
//    if (sel == @selector(run)) {
////        IMP *imp = [self methodForSelector:sel]
//        class_addMethod([self class], @selector(run), (IMP)myRun, "v@:");
//        NSLog(@"动态添加方法");
//        return YES;
//    }

    return [super resolveClassMethod:sel];
}

void myRun(id self, SEL _cmd)
{
    NSLog(@"跑我自己添加的方法---%@", NSStringFromSelector(_cmd));
}

/**
 2.快速消息转发，消息转发重定向 - systemMethod

 @param aSelector 调用的方法
 @return 响应者
 */
- (id)forwardingTargetForSelector:(SEL)aSelector {
    
    NSLog(@"需要转发的方法名称 -- %@", NSStringFromSelector(aSelector));
    
    Sport *sport = [Sport new];
    
    // 判断想要转发到的这个对象是否响应这个方法 - 可以在Sport 注释打开run方法
    if ([sport respondsToSelector:@selector(run)]) {
        
        // 如果代理对象能处理，则转接给代理对象
        return sport;
    }
    else {
         //不能处理进入转发流程
        return [super forwardingTargetForSelector:aSelector];
    }
}

/**
 3.生成方法签名
 */
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    
    // 拿到方法的名称
    NSString *selStr = NSStringFromSelector(aSelector);
    
    // 判断转发是手动生成方法签名
    if ([selStr isEqualToString:@"run"]) {
        
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];
        // v（void） 返回值    @（self）   ：（sel方法）
    }
    
    return [super methodSignatureForSelector:aSelector];
    // 如果 methodSignatureForSelector 返回的NSMethodSignature 是 nil 的话不会继续执行 4.forwardInvocation，转发流程终止，抛出无法处理的异常
    
    /*
     [Sport instanceMethodForSelector:@selector(run)] // 直接拿到一个类的某个方法的签名
     */
}

/**
 4.拿到方法签名，配发消息
 */
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    
    // 拿到方法消息
    SEL selector = [anInvocation selector];
    
    // 看一下目标对象是否响应方法
    Sport *sport = [Sport new];
    
    if ([sport respondsToSelector:selector]) {
        
        [anInvocation invokeWithTarget:sport];
    }
    else {
        
        [super forwardInvocation:anInvocation];
    }
}

/**
 5处理错误消息
 */
- (void)doesNotRecognizeSelector:(SEL)aSelector {
    
    NSString *message = [NSString stringWithFormat:@"--  %@  -- 方法不存在", NSStringFromSelector(aSelector)];
    NSLog(@"%@", message);
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {

    }];
    [alertC addAction:action];
    UIWindow *window = [[UIApplication sharedApplication].delegate window];

    [window.rootViewController presentViewController:alertC animated:YES completion:nil];
}

@end
