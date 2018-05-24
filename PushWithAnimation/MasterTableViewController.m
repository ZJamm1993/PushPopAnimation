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
    }
    return nil;
}

#pragma mark - UIViewControllerAnimatedTransitioning

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.25;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    MasterTableViewController* fromVc=[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    DetailViewController* toVc=[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView* containerView=[transitionContext containerView];
    
    UITableViewCell* cell=[fromVc selectedTableViewCell];
    UIView* snapView=[cell.imageView resizableSnapshotViewFromRect:cell.imageView.bounds afterScreenUpdates:NO withCapInsets:UIEdgeInsetsZero];
    snapView.frame=[cell.imageView convertRect:cell.imageView.bounds toView:containerView];
    
    [containerView addSubview:toVc.view];
    [containerView addSubview:snapView];
    
    toVc.imageView.hidden=YES;
    toVc.view.alpha=0;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        toVc.view.alpha=1;
        snapView.frame=[toVc finishImageViewFrame];
    } completion:^(BOOL finished) {
        toVc.imageView.hidden=NO;
        [snapView removeFromSuperview];
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
    
}

@end
