//
//  ImageCacheObject.h
//  RecCameraSwift
//
//  Created by haruhito on 2015/06/10.
//  Copyright (c) 2015年 FromF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <OLYCameraKit/OLYCamera.h>

@interface ImageCacheObject : NSObject

- (void)setUncahcedImage:(NSString *)imgPath image:(UIImage *)img;
- (UIImage *)getUncachedImage:(NSString *)imgPath;

@end
