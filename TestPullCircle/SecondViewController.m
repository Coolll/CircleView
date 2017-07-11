//
//  SecondViewController.m
//  TestPullCircle
//
//  Created by 龙培 on 17/7/7.
//  Copyright © 2017年 龙培. All rights reserved.


#import "SecondViewController.h"
#import "CircleView.h"
#define PhoneScreen_HEIGHT [UIScreen mainScreen].bounds.size.height
#define PhoneScreen_WIDTH [UIScreen mainScreen].bounds.size.width

static const CGFloat circleRadius = 30;


@interface SecondViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>
{
    CircleView *view;
    
    UITableView *mainTableView;
}
@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self loadCustomView];
}

- (void)loadCustomView
{
    mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, PhoneScreen_WIDTH, PhoneScreen_HEIGHT) style:UITableViewStylePlain];
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    [self.view addSubview:mainTableView];
    
    
    view = [[CircleView alloc]initWithCenterPoint:CGPointMake(PhoneScreen_WIDTH/2, -circleRadius) withRadius:circleRadius withMaxPull:100];
    view.pointColor = [UIColor redColor];
    view.pullType = PullTypeMoveBig;
    view.circleType = CircleTypeSet;
    view.bigChangeRate = 0.5;
    view.smallChangeRate = 0.8;
    view.minRate = 0.3;
    view.contentFont = 14;
    [view handleMaxPull:^{
        
        NSLog(@"做网络请求");
    }];
    
    [mainTableView addSubview:view];

}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static  NSString *identifier = @"CustomTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor lightGrayColor];
    }
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint point = scrollView.contentOffset;
    
    CGFloat pullDownOffset = -point.y;
    
    if ( pullDownOffset < circleRadius*2) {
        
        
        
    }else{

        [view pullDownOffset:pullDownOffset-circleRadius*2];

        
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
