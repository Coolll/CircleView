//
//  ViewController.m
//  TestPullCircle
//
//  Created by 龙培 on 17/7/3.
//  Copyright © 2017年 龙培. All rights reserved.
//控件的思路 http://www.jianshu.com/p/a003516023c3
//问题反馈至 https://github.com/Coolll/CircleView


#import "ViewController.h"
#import "CircleView.h"
#import "SecondViewController.h"

#define PhoneScreen_HEIGHT [UIScreen mainScreen].bounds.size.height
#define PhoneScreen_WIDTH [UIScreen mainScreen].bounds.size.width


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self loadCustomView];
    
    [self loadCircleView];
}

- (void)loadCircleView
{
    //圆圈半径为60，最大拉伸300
    CircleView *circle = [[CircleView alloc]initWithCenterPoint:CGPointMake(PhoneScreen_WIDTH/2, (PhoneScreen_HEIGHT-64)/2) withRadius:60 withMaxPull:300];
    
    //类型为拉伸型
    circle.circleType = CircleTypePull;
    
    //大圆留在原地
    circle.pullType = PullTypeLeaveBig;
    
    //内容文本
    circle.contentString = @"66";
    
    //内容字号
    circle.contentFont = 30;
    
    //圆圈颜色
    circle.pointColor = [UIColor redColor];
    
    //大圆在移动中缩小的速率
    circle.bigChangeRate = 0.4;
    
    //小圆在移动中缩小的速率
    circle.smallChangeRate = 0.7;
    
    //小圆在移动中，最小的比率。如果初始半径为60，这里设置0.3，那么最小的半径则为18
    circle.minRate = 0.3;
    
    //是否需要动画
    circle.needAnimation = YES;
    
    //处理最大拉伸量
    [circle handleMaxPull:^{
        
        NSLog(@"最大拉伸了");
    }];
    
    //处理结束手势时事件
    [circle handleEndTouch:^{
       
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (circle.isEnding) {
                [circle resetOriginCircle];

            }
        });

    }];
    
    
    [self.view addSubview:circle];
}


- (void)loadCustomView
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake((PhoneScreen_WIDTH-100)/2, 100, 100, 50);
    button.layer.cornerRadius = 4.0;
    [button setTitle:@"试试下拉" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor lightGrayColor];
    [button addTarget:self action:@selector(pushAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
}

- (void)pushAction:(UIButton*)btn
{
    SecondViewController *vc = [[SecondViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
