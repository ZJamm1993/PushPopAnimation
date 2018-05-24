//
//  MasterTableViewController.m
//  PushWithAnimation
//
//  Created by ZJam on 2018/5/23.
//  Copyright © 2018年 ZJam. All rights reserved.
//

#import "MasterTableViewController.h"
#import "DetailViewController.h"

@interface MasterTableViewController ()<UINavigationControllerDelegate,UIViewControllerAnimatedTransitioning>
//这两个协议系要遵循，UIViewControllerAnimatedTransitioning用于定义动画，UINavigationControllerDelegate用来调用这个transitioning。

@end

@implementation MasterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"master";
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

//navigation的delegate需要适时改变
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"section:%ld",section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.textLabel.text=[NSString stringWithFormat:@"section:%ld, row:%ld",indexPath.section,indexPath.row];
    cell.imageView.image=[UIImage imageNamed:[NSString stringWithFormat:@"%ld.png",indexPath.row%3]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell* cell=[tableView cellForRowAtIndexPath:indexPath];
    
    self.selectedTableViewCell=cell;
    //这个selectedCell用于稍后的获取快照
    
    UIImageView* view=cell.imageView;
    UIImage* img=view.image;
    DetailViewController* det=[self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    det.image=img;
    [self.navigationController pushViewController:det animated:YES];
}

#pragma mark - Navigation Delegate

- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    if (fromVC==self&&[toVC isKindOfClass:[DetailViewController class]])
    {
        return self;
        //由于自己实现了UIViewControllerAnimatedTransitioning协议，因此返回自己即可
    }
    return nil;
}

#pragma mark - UIViewControllerAnimatedTransitioning

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.25;
    //transition的动画时间
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    //此动画效果：点击的cell中的image移动并放大至下一个controller中，同时这个controller淡入
    MasterTableViewController* fromVc=[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    DetailViewController* toVc=[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    //此view应该是navigationcontroller的容器view
    UIView* containerView=[transitionContext containerView];
    
    //去selectedCell的imageView快照
    UITableViewCell* cell=[fromVc selectedTableViewCell];
    UIView* snapView=[cell.imageView resizableSnapshotViewFromRect:cell.imageView.bounds afterScreenUpdates:NO withCapInsets:UIEdgeInsetsZero];
    snapView.frame=[cell.imageView convertRect:cell.imageView.bounds toView:containerView];
    
    //添加快照view&下一个view
    [containerView addSubview:toVc.view];
    [containerView addSubview:snapView];
    
    cell.imageView.hidden=YES;
    toVc.imageView.hidden=YES;
    toVc.view.alpha=0;
    
    //动画
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        toVc.view.alpha=1;
        snapView.frame=[toVc finishImageViewFrame];
    } completion:^(BOOL finished) {
        toVc.imageView.hidden=NO;
        cell.imageView.hidden=NO;
        
        //完成动画后记得移除临时使用的快照，并调用[completeTransition:]，注意后面是#!cancelled#
        [snapView removeFromSuperview];
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
    
}

@end
