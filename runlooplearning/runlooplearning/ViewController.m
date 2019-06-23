//
//  ViewController.m
//  runlooplearning
//
//  Created by AlexWong on 2019/6/22.
//  Copyright © 2019年 AlexWong. All rights reserved.
//

#import "ViewController.h"
//#import <CoreFoundation/CFRunLoop.h>

@interface ViewController ()

@property (nonatomic,strong) NSThread *thread;

@property (nonatomic,strong) NSPort *port;

@property (nonatomic,strong) NSRunLoop *runloop;

@property (nonatomic,assign) int i;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _i = 0;
    
    UITapGestureRecognizer *tapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(runInMyThread)];
    tapOne.numberOfTapsRequired = 1;
    tapOne.numberOfTouchesRequired = 1;
    
    UITapGestureRecognizer *tapDouble = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(runInMyThreadAndCloseThread)];
    tapDouble.numberOfTapsRequired = 2;
    tapDouble.numberOfTouchesRequired = 1;
    
    [tapOne requireGestureRecognizerToFail:tapDouble];
    
    [self.view addGestureRecognizer:tapOne];
    
    [self.view addGestureRecognizer:tapDouble];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self runInMainThread];
    });

    
    
//GCD直接异步执行，是否会执行
//    dispatch_async(dispatch_get_global_queue(0,0), ^{
//        [self runInOtherThread];
//    });
    
//performSelector:<#(nonnull SEL)#> onThread:<#(nonnull NSThread *)#> withObject:<#(nullable id)#> waitUntilDone:<#(BOOL)#> 方法会启用定时器，而定时器需要有runloop 才能执行
//    dispatch_async(dispatch_get_global_queue(0,0), ^{
//        [self performSelector:@selector(runInOtherThread) onThread:[NSThread currentThread] withObject:nil waitUntilDone:NO];
//        [[NSRunLoop currentRunLoop] run];
//    });

// 一直执行的线程
    _port = [[NSPort alloc] init];
    
    
    [self createALiveAllTheTimeThread];
    
}

- (void)createALiveAllTheTimeThread{
    _thread = [[NSThread alloc] initWithTarget:self selector:@selector(myThreadRun) object:nil];
    _thread.name = @"no dead thread";
    [_thread start];
    
    //延时是为了查看线程执行了函数后的状态，不然可能状态先打印后执行
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"the thread status isfinished:%d iscancel:%d",self.thread.isFinished,self.thread.isCancelled);
    });
}

- (void)myThreadRun{
    NSLog(@"the thread is running");
//不加以下两行代码，线程将不能保活，线程绑定的runloop运行完，runloop和线程都将销毁
    _runloop = [NSRunLoop currentRunLoop];
    [_runloop addPort:_port  forMode:NSDefaultRunLoopMode];
    [_runloop run];

}

- (void)runInMainThread{
    NSLog(@"i am running in main thread!!!,%@",[NSThread currentThread]);
}

- (void)runInOtherThread{
    NSLog(@"i am running in other thread!!!,%@",[NSThread currentThread]);
}

- (void)runInOtherThreadThenCloseThread{
    NSLog(@"i am running in other thread!!!,%@,the thread will die",[NSThread currentThread]);
    [_runloop removePort:_port forMode:NSDefaultRunLoopMode];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"the thread status isfinished:%d iscancel:%d",self.thread.isFinished,self.thread.isCancelled);
    });
}

- (void)runInMyThread{
    [self performSelector:@selector(runInOtherThread) onThread:_thread withObject:nil waitUntilDone:NO];
}

- (void)runInMyThreadAndCloseThread{
    [self performSelector:@selector(runInOtherThreadThenCloseThread) onThread:_thread withObject:nil waitUntilDone:NO];
    
}



@end
