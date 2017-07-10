//
//  ViewController.m
//  TestPullCircle
//
//  Created by 龙培 on 17/7/3.
//  Copyright © 2017年 龙培. All rights reserved.
//

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
    CircleView *circle = [[CircleView alloc]initWithCenterPoint:CGPointMake(PhoneScreen_WIDTH/2, (PhoneScreen_HEIGHT-64)/2) withRadius:60 withMaxPull:300];
    circle.circleType = CircleTypePull;
    circle.pullType = PullTypeLeaveBig;
    circle.contentString = @"66";
    circle.contentFont = 30;
    circle.pointColor = [UIColor redColor];
    circle.bigChangeRate = 0.4;
    circle.smallChangeRate = 0.7;
    circle.minRate = 0.3;
    circle.needAnimation = YES;
    [circle handleMaxPull:^{
        
    }];
    
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
