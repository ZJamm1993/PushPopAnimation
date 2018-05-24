//
//  DetailViewController.h
//  PushWithAnimation
//
//  Created by ZJam on 2018/5/23.
//  Copyright © 2018年 ZJam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (nonatomic,strong) UIImage* image;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

-(CGRect)finishImageViewFrame;

@end
