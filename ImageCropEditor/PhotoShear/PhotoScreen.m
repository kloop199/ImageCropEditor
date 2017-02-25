//
//  PhotoScreen.m
//  相片截图
//
//  Created by selfos on 16/11/27.
//  Copyright © 2016年 selfos. All rights reserved.
//

#import "PhotoScreen.h"
#import "PECropViewController.h"
#if TARGET_IPHONE_SIMULATOR
#define SIMULATOR 1
#elif TARGET_OS_IPHONE
#define SIMULATOR 0
#endif
#define RVC [UIApplication sharedApplication].keyWindow.rootViewController

typedef void(^ShearImage)(UIImage *originalImage);
//在info.plist里面添加Localized resources can be mixed YES 表示是否允许应用程序获取框架库内语言。
@interface PhotoScreen()<UINavigationControllerDelegate, UIImagePickerControllerDelegate,PECropViewControllerDelegate>
{
    UIColor *_barTintColor;
    ShearImage _shearImage;
}
@end
@implementation PhotoScreen

static PhotoScreen *_photoScreen;

+(instancetype)sharePhotoCropManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PhotoScreen *photoScreen=[[self alloc]init];
        _photoScreen=photoScreen;
    });
    return _photoScreen;
}

+(void)editPhotoWithBarTintColor:(UIColor *)color shearImage:(void(^)(UIImage *image))shearImage{
    [[self sharePhotoCropManager] cropEditPhotoWithBarTintColor:color shearImage:^(UIImage *image) {
        if(shearImage){
            shearImage(image);
        }
    }];
}

-(void)cropEditPhotoWithBarTintColor:(UIColor *)color shearImage:(void(^)(UIImage *image))shearImage {
    
    _barTintColor=color;
    
    _shearImage=^(UIImage *image){
        if(shearImage){
            shearImage(image);
        }
    };
    
    //弹出选项
    [self promptWithDelegate];
    
}

- (void)promptWithDelegate{
    
    //弹出提示
    UIAlertController *alertc=[UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    //从相册获取
    UIAlertAction *action1=[UIAlertAction actionWithTitle:@"从相册获取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self openPhotoAlbumWithDelegate];
        
    }];
    
    [alertc addAction:action1];
    //摄像头拍照获取
    UIAlertAction *action2=[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self showCameraDelegate];
    }];
    
    [alertc addAction:action2];
    
    //取消
    UIAlertAction *action3=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        [alertc dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alertc addAction:action3];
    [RVC presentViewController:alertc animated:YES completion:nil];
}

#pragma mark - 代理方法<PECropViewControllerDelegate>

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
    //这里返回一个剪裁好的图片
    if(_shearImage){
        _shearImage(croppedImage);
    }
    _shearImage=nil;
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - 编辑截取图片
- (void)openEditorWithDelegate:(UIImage *)image
{
    PECropViewController *controller = [[PECropViewController alloc] init];
    //隐藏网格限制选项
    controller.toolbarHidden=YES;
    controller.delegate = self;
    controller.image = image;
    
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat length = MIN(width, height);
    controller.imageCropRect = CGRectMake((width - length) / 2,
                                          (height - length) / 2,
                                          length,
                                          length);
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    navigationController.navigationBar.barTintColor=_barTintColor;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [RVC presentViewController:navigationController animated:YES completion:NULL];
}

#pragma mark - 使用系统的方式打开相册
- (void)openPhotoAlbumWithDelegate
{
    //相册
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    
    //设置弹出相册的UINavigationBar
    UINavigationBar *navaBar=[[UINavigationBar alloc]init];
    navaBar.barTintColor=_barTintColor;
    [controller setValue:navaBar forKeyPath:@"_navigationBar"];
    
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    controller.delegate = self;
    [RVC presentViewController:controller animated:YES completion:NULL];
    
}

#pragma mark - 使用系统的方式打开摄像头
- (void)showCameraDelegate
{
    if (!SIMULATOR) {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        //设置弹出摄像头的UINavigationBar
        UINavigationBar *navaBar=[[UINavigationBar alloc]init];
        navaBar.barTintColor=_barTintColor;
        [controller setValue:navaBar forKeyPath:@"_navigationBar"];
        controller.delegate = self;
        controller.sourceType = UIImagePickerControllerSourceTypeCamera;
        [RVC presentViewController:controller animated:YES completion:NULL];
    }else{
        NSLog(@"请使用真机打开");
    }
}

#pragma mark - 图片选择完毕就会调用这个代理方法<UIImagePickerControllerDelegate>
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [self openEditorWithDelegate:image];
    }];
    
}

@end
