//
//  ViewController.m
//  ImageCropEditor
//
//  Created by selfos on 17/2/25.
//  Copyright © 2017年 selfos. All rights reserved.
//

#import "ViewController.h"
#import "PhotoScreen.h"
@interface ViewController ()
{
    __weak UIImageView *_imageView;
}
@end

@implementation ViewController

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //截取头像
    [PhotoScreen editPhotoWithBarTintColor:[UIColor cyanColor] shearImage:^(UIImage *resultImage) {
        _imageView.image=resultImage;
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"截取头像";
    UIImageView *imageView=[[UIImageView alloc]init];
    imageView.backgroundColor=[UIColor grayColor];
    imageView.frame=CGRectMake(0, 0, 160, 160);
    imageView.center=self.view.center;
    imageView.layer.masksToBounds=YES;
    imageView.layer.cornerRadius=imageView.frame.size.height/2;
    imageView.layer.borderWidth=2;
    imageView.layer.borderColor=[UIColor greenColor].CGColor;
    _imageView=imageView;
    [self.view addSubview:imageView];
}


@end
