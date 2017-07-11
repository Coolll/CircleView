//
//  CircleView.m
//  TestPullCircle
//
//  Created by 龙培 on 17/7/3.
//  Copyright © 2017年 龙培. All rights reserved.
//
//控件的思路 http://www.jianshu.com/p/a003516023c3
//问题反馈至 https://github.com/Coolll/CircleView
#import "CircleView.h"


typedef void(^PullBlock)(void);

@interface CircleView ()

/**
 *  小圆半径
 **/
@property (nonatomic,assign) CGFloat circleR;

/**
 *  小圆位于父视图的位置
 **/
@property (nonatomic,assign) CGPoint pinPoint;

/**
 *  小圆半径
 **/
@property (nonatomic,assign) CGFloat originR;

/**
 *  拖拽的距离
 **/
@property (nonatomic,assign) CGFloat pullDis;

/**
 *  小圆圆心
 **/
@property (nonatomic,assign) CGPoint originCenter;

/**
 *  触摸的时候的点
 **/
@property (nonatomic,assign) CGPoint originPoint;

/**
 *  小圆点
 **/
@property (nonatomic,strong) CAShapeLayer *pointLayer;

/**
 *  松手时的角度
 **/
@property (nonatomic,assign) CGFloat endAngle;

/**
 *  达到最大拉伸触发的block
 **/
@property (nonatomic,copy) PullBlock pullBlock;

/**
 *  手势结束最大拉伸触发的block
 **/
@property (nonatomic,copy) PullBlock endBlock;

/**
 *  是否拖拽到最大值了
 **/
@property (nonatomic,readwrite,assign) BOOL isEnding;

/**
 *  合并动画是否结束
 **/
@property (nonatomic,assign) BOOL isEndAnimation;

/**
 *  文本内容
 **/
@property (nonatomic,strong) CATextLayer *contentTextLayer;

/**
 *  非触摸控制的点，当手动设置offset时，有效
 **/
@property (nonatomic,assign) CGPoint offsetCenter;

/**
 *  达到最大值，手动设置时使用（手势调用，每次点击时会进入重置状态）
 **/
@property (nonatomic,assign) BOOL isSetMaxValue;




@end

@implementation CircleView
#pragma mark - 初始化方法

- (instancetype)initWithCenterPoint:(CGPoint)point withRadius:(CGFloat)radius withMaxPull:(CGFloat)pullDistance
{
    self = [super initWithFrame:CGRectMake(point.x-radius, point.y-radius, radius*2, radius*2)];
    
    if (self) {
        
        self.circleR = radius;
        self.originR = radius;
        self.pullDis = pullDistance;
        CGPoint cPoint = CGPointMake(radius, radius);
        self.originCenter = cPoint;
        self.pinPoint = point;
        self.isEnding = NO;
        self.isEndAnimation = NO;
        self.needAnimation = YES;
        self.needHideCircle = YES;
        
        
        _pointLayer = [[CAShapeLayer alloc]init];
        //以（R，R）为圆心，R为半径的圆
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:cPoint radius:radius startAngle:0 endAngle:M_PI*2 clockwise:YES];
        _pointLayer.path = path.CGPath;
        
        self.backgroundColor = [UIColor clearColor];
        [self.layer addSublayer:_pointLayer];
        
        
    }
    
    return self;
}

#pragma mark - 处理最大拉伸的方法

- (void)handleMaxPull:(void(^)(void))maxPullBlock
{
    if (maxPullBlock) {
        self.pullBlock = maxPullBlock;
        
    }
}

- (void)handleEndTouch:(void(^)(void))endTouch
{
    if (endTouch) {
        self.endBlock = endTouch;
    }
}


#pragma mark - 平移手势

- (void)panAction:(UIPanGestureRecognizer*)pan
{
    if (pan.state == UIGestureRecognizerStateBegan) {
        
        //初始触摸的位置，相对于window的point
        self.originPoint = [pan locationInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
        
        //圆的初始半径
        self.circleR = self.originR;
        //重置属性与状态
        self.isEnding = NO;
        self.isEndAnimation = NO;
        self.pointLayer.hidden = NO;
        self.contentTextLayer.hidden = NO;
    }
    
    if (pan.state == UIGestureRecognizerStateChanged) {
        
        
        //触摸变化的点
        CGPoint changePoint = [pan locationInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
        
        //新的圆心，原来的圆心＋触摸变动点值（触摸变化的点－初始触摸的点 ）
        CGPoint newCenter = CGPointMake(self.originCenter.x+(changePoint.x-self.originPoint.x), self.originCenter.y+(changePoint.y-self.originPoint.y));

        //如果此次拉伸到最大值了，那就处理对应的动画
        if (self.isEnding) {
            
            //是否需要回弹动画，分别处理
            if (self.needAnimation) {
             
                //如果有动画，那么就等动画结束了，完整圆圈再做移动
                if (self.isEndAnimation) {
                    
                    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:newCenter radius:self.originR startAngle:0 endAngle:M_PI*2 clockwise:YES];
                    _pointLayer.path = path.CGPath;
                    
                }
                
            }else{
                
                //不需要动画的话，就直接移动
                UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:newCenter radius:self.originR startAngle:0 endAngle:M_PI*2 clockwise:YES];
                _pointLayer.path = path.CGPath;

            }
            
            //如果有文本，隐藏文本
            if (self.contentString) {
                self.contentTextLayer.hidden = YES;
            }
            
            //当拉伸结束，动画也结束，状态恢复后，则不需要继续做操作了
            return;
            
            
        }

        
        //从初始圆心移动到新的圆心
        [self updateCircleWithOriginCenter:self.originCenter withNewCenter:newCenter];

        
    }else if (pan.state == UIGestureRecognizerStateCancelled || pan.state == UIGestureRecognizerStateEnded){
        
        
        if (self.endBlock) {
            self.endBlock();
        }
        
        //如果拉伸到最大值了
        if (_isEnding) {
            
            //把layer隐藏了
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.pointLayer.hidden = YES;
                
            });
            
            //不需要再向外扩展了
            return;
        }
        
        //触摸变化的点
        CGPoint changePoint = [pan locationInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
        //新的圆心，原来的圆心＋触摸变动点值（触摸变化的点－初始触摸的点 ）
        CGPoint endCenter = CGPointMake(self.originCenter.x+(changePoint.x-self.originPoint.x),self.originCenter.y+(changePoint.y-self.originPoint.y));
        
        //100帧，动画总时间0.2
        [self backCircleWithTotal:100 withCurrent:0 withTotalTime:0.2 withOriginCenter:self.originCenter withEndCenter:endCenter];
    }
    
}

#pragma mark - 从起始点到目的点做恢复动画
//total  总帧数
//current 当前第几帧
//totalTime 动画时间
//originCenter 起始点
//endCenter 目标点
- (void)backCircleWithTotal:(NSInteger)total withCurrent:(NSInteger)current withTotalTime:(CGFloat)totalTime withOriginCenter:(CGPoint)originCenter withEndCenter:(CGPoint)endCenter
{
    NSTimeInterval duration = totalTime/total;
    
    __block NSInteger value = current;
    
    //采用递归处理帧
    if (current <= total) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            //比率
            CGFloat rate = value*1.f/total*1.f;
            
            //X，Y值的变化率
            CGFloat xChangeValue = endCenter.x-originCenter.x;
            CGFloat yChangeValue = endCenter.y-originCenter.y;
            
            //回弹时，不同时刻的圆心位置
            CGPoint backCenter = CGPointMake(endCenter.x-xChangeValue*rate, endCenter.y-yChangeValue*rate);
            //绘制曲线
            [self updateCircleWithOriginCenter:originCenter withNewCenter:backCenter];
            
            //递归调用，继续更新
            [self backCircleWithTotal:total withCurrent:value+1 withTotalTime:totalTime withOriginCenter:originCenter withEndCenter:endCenter];
            
            if (value == total) {
                //当完成整个回弹时，设置属性，重置圆的位置
                self.isEndAnimation = YES;
            }
        });
    
    }else{
        //如果本次拖拽结束了，不需要回弹动画了
        if (self.isEnding) {
           
            return;
        }
        
        //未拉到最大值，放手的动画处理
        CGFloat rate = 0.1;
        
        //X,Y的变化值
        CGFloat xChangeValue = endCenter.x-originCenter.x;
        CGFloat yChangeValue = endCenter.y-originCenter.y;
        
        //初始位置的左上侧
        CGPoint backCenter = CGPointMake(originCenter.x-xChangeValue*rate-self.originR, originCenter.y-yChangeValue*rate-self.originR);
        //初始位置的右下侧
        CGPoint foreCenter = CGPointMake(originCenter.x+xChangeValue*rate/2-self.originR, originCenter.y+yChangeValue*rate/2-self.originR);
        //初始位置的左上侧，较靠近圆心
        CGPoint backTwoCenter = CGPointMake(originCenter.x-xChangeValue*rate/3-self.originR, originCenter.y-yChangeValue*rate/3-self.originR);

        //动画
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        animation.calculationMode = kCAAnimationLinear;
        
        CGMutablePathRef path = CGPathCreateMutable();
        //移动到圆心
        CGPathMoveToPoint(path, NULL,originCenter.x-self.originR, originCenter.y-self.originR);
        //圆心左上侧
        CGPathAddLineToPoint(path, NULL, backCenter.x, backCenter.y);
        //圆心的右下侧
        CGPathAddLineToPoint(path, NULL, foreCenter.x, foreCenter.y);
        //圆心的左上侧，近圆心
        CGPathAddLineToPoint(path, NULL, backTwoCenter.x, backTwoCenter.y);
        //圆心的右下侧，近圆心
        CGPathAddLineToPoint(path, NULL, originCenter.x-self.originR, originCenter.y-self.originR);
        animation.path = path;
        animation.duration = 0.35;
        [self.pointLayer addAnimation:animation forKey:@"pointBackAnimation"];
        
        
    }
}

#pragma mark - 更新视图，从初始圆心拉伸到目标圆心位置

- (void)updateCircleWithOriginCenter:(CGPoint)originCenter withNewCenter:(CGPoint)newCenter
{
    
      //拖拽的距离，等于两个圆心的距离
    double moveDistance = (double)sqrt((newCenter.y-originCenter.y)*(newCenter.y-originCenter.y) + (newCenter.x-originCenter.x)*(newCenter.x-originCenter.x));
    if (moveDistance == 0) {
        return;
    }
    //移动的水平角度（两圆心连线与水平面夹角）
    //反正切函数很方便，但因为反正切函数在0的位置突变，从-M_PI/2变为 M_PI/2，无法满足我们拖动时的渐变需求，故舍弃。我们使用反正弦函数。
    //正弦函数＝对边／斜边  两个圆心之间的连线为斜边，对边是Y轴的垂直距离
    double sinValue = (double)(newCenter.y-originCenter.y)/(double)sqrt((newCenter.y-originCenter.y)*(newCenter.y-originCenter.y) + (newCenter.x-originCenter.x)*(newCenter.x-originCenter.x));
    //获取弧度
    double angle = asin(sinValue);
    
    double rate = moveDistance/self.pullDis;
    
    if (rate >= 1) {
        rate = 1;
        
        //如果拖拽结束了，那就不做操作，否则会死循环。因为拖拽结束，会进行恢复绘制，恢复绘制方法中会调用本方法，然后本方法再调用恢复绘制方法。。。
        if (self.isEnding) {
            return;
        }
        
        //达到最大值，断开
        self.isEnding = YES;
        
        //如果有回调，则触发
        if (self.pullBlock) {
            self.pullBlock();
        }
        

        
        
        if (self.needAnimation) {
            
            //将原始位置的圆进行恢复绘制，就是把原始位置的小圆拉过来。在手指触摸的位置合二为一
            [self backCircleWithTotal:100 withCurrent:0 withTotalTime:0.05 withOriginCenter:newCenter withEndCenter:originCenter];
        }else{
            
            //拉伸到最大值时，如果不需要动画，且是用户设置的类型，那么隐藏layer
            if (self.circleType == CircleTypeSet) {
                self.isSetMaxValue = YES;
                [self resetOriginCircle];
                self.pointLayer.hidden = YES;

            }

        }
        
        
        //如果有文本，隐藏文本
        if (self.contentString) {
            self.contentTextLayer.hidden = YES;
        }
        
        
        return;
    }
    
    CGFloat bigCircleRate = self.bigChangeRate > 0 ? self.bigChangeRate:1/3;
    CGFloat smallCircleRate = self.smallChangeRate > 0 ? self.smallChangeRate:1;
    
    //新的半径
    CGFloat newRadius = 0;
    
    switch (self.pullType) {
        case PullTypeLeaveBig:
        {
            //如果是拉到最大值，结束绘制，合二为一的过程，那么起始圆和目标圆半径互换
            //比如说：大半径留在原地，小半径被拖拽走的这种情况
            //当我向外拉的时候：拖动的圆半径较小，小圆移动
            //当我未拉到最大值，小圆回去，小圆移动
            //当我拉到最大值，大圆向小圆合并。大圆移动
            if (self.isEnding) {
                self.circleR = self.originR*((1-rate*smallCircleRate)>self.minRate?(1-rate*smallCircleRate):self.minRate);
                newRadius = self.originR*((1-rate*bigCircleRate)>self.minRate?(1-rate*bigCircleRate):self.minRate);

            }else{
                newRadius = self.originR*((1-rate*smallCircleRate)>self.minRate?(1-rate*smallCircleRate):self.minRate);
                self.circleR = self.originR*((1-rate*bigCircleRate)>self.minRate?(1-rate*bigCircleRate):self.minRate);
            }
        }
            break;
            
        case PullTypeMoveBig:
        {
            if (self.isEnding) {
                newRadius = self.originR*((1-rate*smallCircleRate)>self.minRate?(1-rate*smallCircleRate):self.minRate);
                self.circleR = self.originR*((1-rate*bigCircleRate)>self.minRate?(1-rate*bigCircleRate):self.minRate);

            }else{
                self.circleR = self.originR*((1-rate*smallCircleRate)>self.minRate?(1-rate*smallCircleRate):self.minRate);
                newRadius = self.originR*((1-rate*bigCircleRate)>self.minRate?(1-rate*bigCircleRate):self.minRate);
            }
            
            
        }
            break;
        default:
            break;
    }
    
    
    //创建新的BezierPath
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    if (newCenter.x-originCenter.x < 0) {
        
        //圆的中心对称轴，左侧与右侧的计算不一样
        
        //初始圆的底部的点
        CGPoint originBottomPoint = CGPointMake(originCenter.x+sin(angle)*self.circleR, originCenter.y+cos(angle)*self.circleR);
        //初始圆的顶部的点
        CGPoint originTopPoint = CGPointMake(originCenter.x-sin(angle)*self.circleR, originCenter.y-cos(angle)*self.circleR);
        
        //新圆心的左上角的点
        CGPoint newTopPoint = CGPointMake(newCenter.x-sin(angle)*newRadius, newCenter.y-cos(angle)*newRadius);
        //新圆心的下部的点
        CGPoint newBottomPoint = CGPointMake(newCenter.x+sin(angle)*newRadius, newCenter.y+cos(angle)*newRadius);
        
        
        //两圆心连线中点
        CGPoint controlPoint = CGPointMake(originCenter.x+(newCenter.x-originCenter.x)/2, originCenter.y+(newCenter.y-originCenter.y)/2);
        
        //初始圆顶部点与新圆的顶部点连线的中点
        CGPoint topMiddlePoint = CGPointMake((newTopPoint.x+originTopPoint.x)/2, (newTopPoint.y+originTopPoint.y)/2);
        
        //上部控制点的X坐标，与拉伸比例有关，未拉伸时，取顶部点连线中点，拉伸最大时，取两圆心连线中点
        CGFloat topX = topMiddlePoint.x + (controlPoint.x-topMiddlePoint.x)*rate;
        //上部控制点的Y坐标，与拉伸比例有关
        CGFloat topY = topMiddlePoint.y + (controlPoint.y-topMiddlePoint.y)*rate;
        
        //拉伸时，上部的控制点。不断变化的
        CGPoint topControlPoint = CGPointMake(topX, topY);
        
        //两个圆下部点连线的中点
        CGPoint bottomMiddlePoint = CGPointMake((newBottomPoint.x+originBottomPoint.x)/2, (newBottomPoint.y+originBottomPoint.y)/2);
        //下部点的x，随比例变化
        CGFloat bottomX = bottomMiddlePoint.x + (controlPoint.x-bottomMiddlePoint.x)*rate;
        //下部点的y，随比例变化
        CGFloat bottomY = bottomMiddlePoint.y + (controlPoint.y-bottomMiddlePoint.y)*rate;
        //拉伸时，下部控制点
        CGPoint bottomControlPoint = CGPointMake(bottomX, bottomY);
        
        
        //移动到初始圆的下部点
        [path moveToPoint:originBottomPoint];
        
        //原始的圆，右半侧，逆时针画圆
        [path addArcWithCenter:originCenter radius:self.circleR startAngle:M_PI/2-angle endAngle:M_PI*3/2-angle clockwise:NO];
        
        //从原始圆的顶部，连线到新圆的顶部，上部点为控制点
        [path addQuadCurveToPoint:newTopPoint controlPoint:topControlPoint];
        
        //新圆的左侧，逆时针画圆
        [path addArcWithCenter:newCenter radius:newRadius startAngle:M_PI*3/2-angle endAngle:M_PI*5/2-angle clockwise:NO];
        
        
        //从新圆的底部，连接到初始圆的底部点，下部点为控制点
        [path addQuadCurveToPoint:originBottomPoint controlPoint:bottomControlPoint];
        
        
    }else{
        
        
        //初始圆的下部点
        CGPoint originBottomPoint = CGPointMake(originCenter.x-sin(angle)*self.circleR, originCenter.y+cos(angle)*self.circleR);
        
        CGPoint originTopPoint = CGPointMake(originCenter.x+sin(angle)*self.circleR, originCenter.y-cos(angle)*self.circleR);
        
        //新圆心的左上角的点
        CGPoint newTopPoint = CGPointMake(newCenter.x+sin(angle)*newRadius, newCenter.y-cos(angle)*newRadius);
        CGPoint newBottomPoint = CGPointMake(newCenter.x-sin(angle)*newRadius, newCenter.y+cos(angle)*newRadius);
        
        //两圆心连线中点
        CGPoint controlPoint = CGPointMake(originCenter.x+(newCenter.x-originCenter.x)/2, originCenter.y+(newCenter.y-originCenter.y)/2);
        
        
        //初始圆顶部点与新圆的顶部点连线的中点
        CGPoint topMiddlePoint = CGPointMake((newTopPoint.x+originTopPoint.x)/2, (newTopPoint.y+originTopPoint.y)/2);
        
        //上部控制点的X坐标，与拉伸比例有关，未拉伸时，取顶部点连线中点，拉伸最大时，取两圆心连线中点
        CGFloat topX = topMiddlePoint.x + (controlPoint.x-topMiddlePoint.x)*rate;
        //上部控制点的Y坐标，与拉伸比例有关
        CGFloat topY = topMiddlePoint.y + (controlPoint.y-topMiddlePoint.y)*rate;
        
        //拉伸时，上部的控制点。不断变化的
        CGPoint topControlPoint = CGPointMake(topX, topY);
        
        //两个圆下部点连线的中点
        CGPoint bottomMiddlePoint = CGPointMake((newBottomPoint.x+originBottomPoint.x)/2, (newBottomPoint.y+originBottomPoint.y)/2);
        //下部点的x，随比例变化
        CGFloat bottomX = bottomMiddlePoint.x + (controlPoint.x-bottomMiddlePoint.x)*rate;
        //下部点的y，随比例变化
        CGFloat bottomY = bottomMiddlePoint.y + (controlPoint.y-bottomMiddlePoint.y)*rate;
        //拉伸时，下部控制点
        CGPoint bottomControlPoint = CGPointMake(bottomX, bottomY);
        
        
        
        [path moveToPoint:originBottomPoint];
        
        //原始的圆，左半侧，顺时针画圆
        [path addArcWithCenter:originCenter radius:self.circleR startAngle:M_PI/2+angle endAngle:M_PI*3/2+angle clockwise:YES];
        
        //添加曲线到新圆的顶部
        [path addQuadCurveToPoint:newTopPoint controlPoint:topControlPoint];
        
        //新圆的右侧，顺时针画圆
        [path addArcWithCenter:newCenter radius:newRadius startAngle:M_PI*3/2+angle endAngle:M_PI*5/2+angle clockwise:YES];
        
        //添加曲线到新圆的底部点
        [path addQuadCurveToPoint:originBottomPoint controlPoint:bottomControlPoint];
        
        
    }
    
    //更新layer
    self.pointLayer.path = path.CGPath;

}

#pragma mark - 恢复初始圆

- (void)resetOriginCircle
{
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:self.originCenter radius:self.originR startAngle:0 endAngle:M_PI*2 clockwise:YES];
    _pointLayer.path = path.CGPath;
    _pointLayer.hidden = NO;
    
    //展示文本
    if (self.contentString) {
        self.contentTextLayer.hidden = NO;
    }
}

#pragma mark - 文本内容

- (void)setContentString:(NSString *)contentString
{
    _contentString = contentString;
    self.contentTextLayer.string = contentString;
}

#pragma mark - 文本字号

- (void)setContentFont:(NSInteger)contentFont
{
    _contentFont = contentFont;
    
    self.contentTextLayer.frame = CGRectMake(self.originCenter.x-self.originR, self.originCenter.y-(contentFont*1.2)/2, self.originR*2, contentFont*1.2);
    
    UIFont *font = [UIFont systemFontOfSize:contentFont];
    CFStringRef fontName = (__bridge CFStringRef)font.fontName;
    CGFontRef fontRef = CGFontCreateWithFontName(fontName);
    self.contentTextLayer.font = fontRef;
    self.contentTextLayer.fontSize = font.pointSize;
    
    CGFontRelease(fontRef);

}

#pragma mark - 文本property

- (CATextLayer*)contentTextLayer
{
    if (!_contentTextLayer) {
        
        _contentTextLayer = [CATextLayer layer];
        _contentTextLayer.frame = CGRectMake(self.originCenter.x-self.originR, self.originCenter.y-10, self.originR*2, 20);
        _contentTextLayer.foregroundColor = [UIColor whiteColor].CGColor;
        _contentTextLayer.backgroundColor = [UIColor clearColor].CGColor;
        
        UIFont *font = [UIFont systemFontOfSize:20.0];
        CFStringRef fontName = (__bridge CFStringRef)font.fontName;
        CGFontRef fontRef = CGFontCreateWithFontName(fontName);
        _contentTextLayer.font = fontRef;
        _contentTextLayer.fontSize = font.pointSize;
        _contentTextLayer.contentsScale = [UIScreen mainScreen].scale;
        
        CGFontRelease(fontRef);
        
        _contentTextLayer.alignmentMode = kCAAlignmentCenter;
        
        [self.layer addSublayer:_contentTextLayer];
    }
    
    return _contentTextLayer;

}


#pragma mark - 圆点的颜色

- (void)setPointColor:(UIColor *)pointColor
{
    _pointColor = pointColor;
    
    self.pointLayer.fillColor = [UIColor redColor].CGColor;
}

#pragma mark - 设置类型，设置型和拉伸型

- (void)setCircleType:(CircleType)circleType
{
    _circleType = circleType;
    
    if (circleType == CircleTypePull) {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panAction:)];
        [self addGestureRecognizer:pan];
        
    }else{
        self.userInteractionEnabled = NO;
    }

}

#pragma mark - 下拉偏移量

- (void)pullDownOffset:(CGFloat)offset
{

    if (offset <= 10) {
        [self refreshView];
    }
    
    if (offset < 0) {
        return;
    }
    
    
    //新的圆心，原来的圆心＋触摸变动点值（触摸变化的点－初始触摸的点 ）
    self.offsetCenter = CGPointMake(self.originCenter.x, self.originCenter.y-(offset));
    
    if (offset > self.pullDis) {
        
        if (self.pullBlock && !self.isSetMaxValue) {
            
            self.pullBlock();
        }
        
        self.isSetMaxValue = YES;

        self.pointLayer.hidden = YES;
        
       
        
    }else{
        
        self.needAnimation = NO;
        [self updateCircleWithOriginCenter:self.originCenter withNewCenter:self.offsetCenter];

    }

}




//用户设置偏移量，下拉恢复时，刷新
- (void)refreshView
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.pointLayer.hidden = NO;
        
        if (self.contentString) {
            
            self.contentTextLayer.hidden = NO;
        }
        
    });
    self.isEnding = NO;
    self.isSetMaxValue = NO;
}



@end
