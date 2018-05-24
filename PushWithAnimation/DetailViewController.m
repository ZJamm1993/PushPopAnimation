//
//  DetailViewController.m
//  PushWithAnimation
//
//  Created by ZJam on 2018/5/23.
//  Copyright © 2018年 ZJam. All rights reserved.
//

#import "DetailViewController.h"
#import "MasterTableViewController.h"

@interface DetailViewController ()<UINavigationControllerDelegate,UIViewControllerAnimatedTransitioning>
@property (nonatomic,strong) UIPercentDrivenInteractiveTransition* interactivePopTransition;
@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title=@"detail";
    self.imageView.image=self.image;
    self.imageView.frame=[self finishImageViewFrame];
    
    UIScreenEdgePanGestureRecognizer *popRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePopRecognizer:)];
    popRecognizer.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:popRecognizer];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.delegate=self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.navigationController.delegate == self) {
        self.navigationController.delegate = nil;
    }
}

- (void)handlePopRecognizer:(UIScreenEdgePanGestureRecognizer*)recognizer {
    // 计算用户手指划了多远
    CGFloat progress = [recognizer translationInView:self.view].x / (self.view.bounds.size.width * 1.0);
    progress = MIN(1.0, MAX(0.0, progress));
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        // 创建过渡对象，弹出viewController
        self.interactivePopTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        // 更新 interactive transition 的进度
        [self.interactivePopTransition updateInteractiveTransition:progress];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        // 完成或者取消过渡
        if (progress > 0.5) {
            [self.interactivePopTransition finishInteractiveTransition];
        }
        else {
            //这里的cancel是动画结束时建议用[completeTransition:#!cancelled#]的原因
            [self.interactivePopTransition cancelInteractiveTransition];
        }
        
        self.interactivePopTransition = nil;
    }
}

-(CGRect)finishImageViewFrame
{
    CGSize size=CGSizeMake([[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.width/4.0*3.0);
    return CGRectMake(0, [[UIScreen mainScreen]bounds].size.height/2-size.height/2, size.width,size.height);
}

#pragma mark - Navigation Delegate

- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    if (fromVC==self&&[toVC isKindOfClass:[MasterTableViewController class]])
    {
        return self;
    }
    return nil;
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                         interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    // 检查是否是我们的自定义过渡
    if ([animationController isKindOfClass:[self class]]) {
        return self.interactivePopTransition;
    }
    else {
        return nil;
    }
}

#pragma mark - UIViewControllerAnimatedTransitioning

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.25;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    DetailViewController* fromVc=[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    MasterTableViewController* toVc=[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView* containerView=[transitionContext containerView];
    
    UIView* snapView=[fromVc.imageView resizableSnapshotViewFromRect:fromVc.imageView.bounds afterScreenUpdates:NO withCapInsets:UIEdgeInsetsZero];
    snapView.frame=fromVc.imageView.frame;
    
    toVc.view.alpha=0;
    fromVc.imageView.hidden=YES;
    [containerView addSubview:toVc.view];
    [containerView addSubview:snapView];
    
    UITableViewCell* cell=toVc.selectedTableViewCell;
    cell.imageView.hidden=YES;
    CGRect imgFrame=[cell.imageView convertRect:cell.imageView.bounds toView:containerView];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        toVc.view.alpha=1;
        snapView.frame=imgFrame;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        [snapView removeFromSuperview];
        fromVc.imageView.hidden=NO;
        cell.imageView.hidden=NO;
    }];
    
}

@end
