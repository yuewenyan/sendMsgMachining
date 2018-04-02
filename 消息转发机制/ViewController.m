//
//  ViewController.m
//  消息转发机制
//
//  Created by 闫跃文 on 2018/3/15.
//  Copyright © 2018年 闫跃文. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import "Sport.h"
#import "NSObject+YYKVO.h"

@interface ViewController ()

@property (nonatomic, strong) Sport * sp;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
//    观察者kvo
    
    self.sp = [[Sport alloc] init];
    
//    [sp addObserver:self forKeyPath:@"time" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];

//    设置可以观察某个值 - 建议写到setter方法中
//    [sp willChangeValueForKey:@"time"];
    self.sp.time = 100;
    self.sp.ttt = @"dddd";
//    [sp didChangeValueForKey:@"time"];
    
    
    [self.sp yy_addObserver:self forKeyPath:@"ttt" block:^(id observer, NSString *keyPath, id newValue, id oldValue) {

        NSLog(@"%@   %@", newValue, oldValue);
    }];
    self.sp.ttt = @"eeeee";    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    NSLog(@"%@", change);
}


- (IBAction)sendMessage:(id)sender {
    
    Person *person = [Person new];
    // 通过消息转发机制使得对象调用未实现的方法时不会崩溃
    [person run];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
