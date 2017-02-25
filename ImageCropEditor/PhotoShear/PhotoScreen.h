//
//  PhotoScreen.h
//  照片截图
//
//  Created by selfos on 16/11/27.
//  Copyright © 2016年 selfos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface PhotoScreen : NSObject
/**弹出选择照片并剪裁*/
+(void)editPhotoWithBarTintColor:(UIColor *)color shearImage:(void(^)(UIImage *image))shearImage;
@end
