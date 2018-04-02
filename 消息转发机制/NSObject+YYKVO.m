//
//  NSObject+YYKVO.m
//  消息转发机制
//
//  Created by 闫跃文 on 2018/3/26.
//  Copyright © 2018年 闫跃文. All rights reserved.
//

#import "NSObject+YYKVO.h"
#import <objc/message.h>

static NSString * KClassPrefix    =   @"YY_KVO_";
static NSString * KCCKVOAssoncikey    =   @"KCCKVOAssoncikey";


@interface YYKVO_Info : NSObject

@property (nonatomic, copy) YYKVOBlock block;

@property (nonatomic, weak) NSObject * observer;

@property (nonatomic, copy) NSString * keyPath;


@end

@implementation YYKVO_Info

- (instancetype)initWithObserver:(NSObject *)observer keyPath:(NSString *)keyPath withBlock:(YYKVOBlock)block {
    
    if (self = [super init]) {
        
        self.block = block;
        
        self.keyPath = keyPath;
        
        self.observer = observer;
    }
    return self;
}

@end


@implementation NSObject (YYKVO)

- (void)yy_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath block:(YYKVOBlock)block {
    
    //1: 判断keyPath  ===>>> setter
    Class superClass = object_getClass(self);
    
    //setName
    SEL setterSeletor = NSSelectorFromString(setterFromGetter(keyPath));
    
    Method setterMethod = class_getInstanceMethod(superClass, setterSeletor);
    // 判断类中是否含有这个属性 - 通过判断是否含有setter即可
    if (!setterMethod) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"In [ %@ ] can't find settor method!", self] userInfo:nil];
    }
    
    // 动态创建子类 - NSKVONotifiying_A
    Class newClass = [self createClassFromSuperName:NSStringFromClass(superClass)];

    // 替换父类
    object_setClass(self, newClass);
    
    // 添加setter
    if (![self hasMethod:setterSeletor]) {
        
        const char *types = method_getTypeEncoding(setterMethod);
        class_addMethod(newClass, setterSeletor, (IMP)YYKVO_Setter, types);
    }
    
    YYKVO_Info * kvoInfo = [[YYKVO_Info alloc] initWithObserver:self keyPath:keyPath withBlock:block];
    
    NSMutableArray *infoArrayAY = objc_getAssociatedObject(self, (__bridge const void * _Nonnull)(KCCKVOAssoncikey));
    
    if (!infoArrayAY) {
        
        infoArrayAY = [NSMutableArray array];
        /**
         动态添加属性
         1:源对象 给谁添加属性
         2:关联的关键字:
         3:关联对象
         4:关联策略
         */
        objc_setAssociatedObject(self, (__bridge const void * _Nonnull)(KCCKVOAssoncikey), infoArrayAY, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    [infoArrayAY addObject:kvoInfo];
}

/**
 创建新类
 */
- (Class)createClassFromSuperName:(NSString *)superName {
    
    // 1. 动态创建类
    /*     1:父类 2:心累名字 3:开辟的空间     */
    // 1.1 获取父类方法
    Class superClass = NSClassFromString(superName);
    // 1.2
    NSString *className = [KClassPrefix stringByAppendingString:superName];
    
    Class newClass = objc_allocateClassPair(superClass, className.UTF8String, 0);
    
    // 2. 添加方法 class
    
    //SEL:  @seletor(SEL):方法选择器  //方法编号  ===> 函数指针
    //IMP: 指针 ==>>>> 方法的实现
    Method classMethod = class_getClassMethod(superClass, @selector(class));
    const char *types = method_getTypeEncoding(classMethod);
    
    class_addMethod(newClass, @selector(class), (IMP)YYKVO_Class, types);
    
    // 注册类
    objc_registerClassPair(newClass);
    
    return newClass;
}


#pragma mark - 函数方法 - get set

static void YYKVO_Setter(id self, SEL _cmd, id newValue) {
    
    NSString *getterName = getterFromSetter(NSStringFromSelector(_cmd));
    
    if (!getterName) {
        
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"In [ %@ ] can't find getter method!", self] userInfo:nil];
    }
    
    id oldValue = [self valueForKey:getterName];
    
    [self willChangeValueForKey:getterName];
    
    // 此处注意内存泄漏
    void(*msg_sendYYKVO)(void *, SEL, id) = (void *)objc_msgSendSuper;
    
    struct objc_super superClassStruck = {
        
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self))
    };
    
    msg_sendYYKVO(&superClassStruck, _cmd , newValue);
    
    [self didChangeValueForKey:getterName];
    
    //关联属性的使用
    //info  block(oldValue newValue);
    NSMutableArray *infoArr = objc_getAssociatedObject(self, (__bridge const void * _Nonnull)(KCCKVOAssoncikey));
    
    for (YYKVO_Info *info in infoArr) {
        
        if ([info.keyPath isEqualToString:getterName]) {
            
            dispatch_async(dispatch_queue_create(0, 0), ^{
                
                info.block(self, info.keyPath, oldValue, newValue);
            });
        }
    }
}

static Class YYKVO_Class(id self){
    
    return class_getSuperclass(object_getClass(self));
}

/**
 判断是否含有sel方法
 */
- (BOOL)hasMethod:(SEL)selector {
    
    Class observedClass = object_getClass(self);
    unsigned int methodCount = 0;
    
    //得到一堆方法的名字列表  //class_copyIvarList 实例变量  //class_copyPropertyList 得到所有属性名字
    Method *methodList = class_copyMethodList(observedClass, &methodCount);
    for (int i = 0; i< methodCount; i++) {
      
        SEL sel = method_getName(methodList[i]);
        
        if (sel == selector) {
            
            free(methodList); //防泄漏===>>>递归方式去拿方法
            return YES;
        }
    }
    free(methodList);
    return NO;
}

/**
 通过getter方法名获取setter方法名
 */
static NSString * setterFromGetter(NSString * getter) {
    
    if (getter.length <= 0) {
        
        return nil;
    }
    
    NSString *frontString = [getter substringToIndex:1].uppercaseString;
    NSString *afterString = [getter substringFromIndex:1];
    
    return [NSString stringWithFormat:@"set%@%@:", frontString, afterString];
}


/**
 通过setter方法名获取getter方法名
 */
static NSString * getterFromSetter(NSString *setter) {
    
    if (setter.length <= 4 || ![setter hasPrefix:@"set"] || ![setter hasSuffix:@":"]) {
        
        return nil;
    }
    
    NSString *getString = [setter substringFromIndex:3];
    getString = [getString stringByReplacingOccurrencesOfString:@":" withString:@""];
    return [getString lowercaseString];
}


@end
