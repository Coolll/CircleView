//
//  CircleView.h
//  TestPullCircle
//
//  Created by 龙培 on 17/7/3.
//  Copyright © 2017年 龙培. All rights reserved.
//控件的思路 http://www.jianshu.com/p/a003516023c3
//问题反馈至 https://github.com/Coolll/CircleView

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,PullType) {
    PullTypeLeaveBig,//拖拽时，大圆遗留在原位置，类似于下拉刷新
    PullTypeMoveBig//拖拽时，大圆被移动，类似于消息提示
};

typedef NS_ENUM(NSInteger,CircleType) {
    CircleTypePull,//可用来拖动的圆
    CircleTypeSet//设置下拉的圆
};

@interface CircleView : UIView

/**
 *  圆圈类型，一种是下拉的，一种是拖动的
 **/
@property (nonatomic,assign) CircleType circleType;

/**
 *  颜色
 **/
@property (nonatomic,strong) UIColor *pointColor;

/**
 *  内容
 **/
@property (nonatomic,copy) NSString *contentString;

/**
 *  内容的字号
 **/
@property (nonatomic,assign) NSInteger contentFont;

/**
 *  类型
 **/
@property (nonatomic,assign) PullType pullType;

/**
 *  圆缩小的最小比例,比如原始小圆半径为40，设置minRate为0.3，那么拉伸时，半径为12则，不再拉伸了
 **/
@property (nonatomic,assign) CGFloat minRate;

/**
 *  拖动时，大圆的半径变化率，0表示不变，1表示与拉伸率保持一致，越大，变化越快，默认0.3333
 **/
@property (nonatomic,assign) CGFloat bigChangeRate;
/**
 *  拖动时，小圆的半径变化率，0表示不变，1表示与拉伸率保持一致，越大，变化越快，默认1
 **/
@property (nonatomic,assign) CGFloat smallChangeRate;

/**
 *  达到最大拖拽值时，是否需要合并的动画，默认YES
 **/
@property (nonatomic,assign) BOOL needAnimation;

/**
 *  达到最大拖拽值时，是否要隐藏圆圈，默认YES。如果需要拖拽最大值后继续移动，那就设置为NO
 **/
@property (nonatomic,assign) BOOL needHideCircle;

/**
 *  是否拖拽到最大值了
 **/
@property (nonatomic,readonly,assign) BOOL isEnding;


//初始化方法
//point为圆心位于父视图的位置
//radius 圆的半径
//pullDistance 拉伸的最大距离，达到后，会断开
- (instancetype)initWithCenterPoint:(CGPoint)point withRadius:(CGFloat)radius withMaxPull:(CGFloat)pullDistance;

//当拉伸达到最大值时的处理
- (void)handleMaxPull:(void(^)(void))maxPullBlock;

//点击完毕后的处理
- (void)handleEndTouch:(void(^)(void))endTouch;


//设置垂直距离的偏移
- (void)pullDownOffset:(CGFloat)offset;

//重置视图的状态
- (void)resetOriginCircle;

@end
