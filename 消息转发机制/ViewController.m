//
//  ViewController.m
//  消息转发机制
//
//  Created by 闫跃文 on 2018/3/15.
//  Copyright © 2018年 闫跃文. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
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
