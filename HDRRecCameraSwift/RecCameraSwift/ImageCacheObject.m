//
//  ImageCacheObject.m
//  RecCameraSwift
//
//  Created by haruhito on 2015/06/10.
//  Copyright (c) 2015年 FromF. All rights reserved.
//

#import "ImageCacheObject.h"


@interface ImageCacheObject()

@property (nonatomic , strong) NSCache *cache;

@end

@implementation ImageCacheObject

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cache = [[NSCache alloc] init] ;
        self.cache.countLimit = 50;
    }
    return self;
}

- (void)setUncahcedImage:(NSString *)imgPath image:(UIImage *)img
{
    [self.cache setObject:img forKey:imgPath];
}

- (UIImage *)getUncachedImage:(NSString *)imgPath{
    
    UIImage *image = [self.cache objectForKey:imgPath];
    
    if (image == nil) {
        //image = [[UIImage alloc] initWithContentsOfFile:imgPath];
        //[self.cache setObject:image forKey:imgPath];
    }
    
    return image;
}

-(void)takePictureHDR:(OLYCamera *)camera
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [camera lockAutoExposure:nil];
    [camera lockAutoFocus:^(NSDictionary *info) {
        NSLog(@"lockAutoFocus comp");
        dispatch_semaphore_signal(semaphore);
    } errorHandler:^(NSError *error) {
        NSLog(@"lockAutoFocus err");
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [camera setCameraPropertyValue:@"EXPREV" value:@"<EXPREV/+2.0>" error:nil];
    [camera takePicture:nil progressHandler:^(OLYCameraTakingProgress progress, NSDictionary *info) {
        NSLog(@"takePicture progress");
    } completionHandler:^(NSDictionary *info) {
        NSLog(@"takePicture comp");
        dispatch_semaphore_signal(semaphore);
    } errorHandler:^(NSError *error) {
        NSLog(@"takePicture err");
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    while (camera.mediaBusy) {
        NSLog(@"media busy");
        [NSThread sleepForTimeInterval:0.5f];
    }
    [camera setCameraPropertyValue:@"EXPREV" value:@"<EXPREV/0.0>" error:nil];
    [camera takePicture:nil progressHandler:^(OLYCameraTakingProgress progress, NSDictionary *info) {
        NSLog(@"takePicture progress");
    } completionHandler:^(NSDictionary *info) {
        NSLog(@"takePicture comp");
        dispatch_semaphore_signal(semaphore);
    } errorHandler:^(NSError *error) {
        NSLog(@"takePicture err");
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    while (camera.mediaBusy) {
        NSLog(@"media busy");
        [NSThread sleepForTimeInterval:0.5f];
    }
    [camera setCameraPropertyValue:@"EXPREV" value:@"<EXPREV/-2.0>" error:nil];
    [camera takePicture:nil progressHandler:^(OLYCameraTakingProgress progress, NSDictionary *info) {
        NSLog(@"takePicture progress");
    } completionHandler:^(NSDictionary *info) {
        NSLog(@"takePicture comp");
        dispatch_semaphore_signal(semaphore);
    } errorHandler:^(NSError *error) {
        NSLog(@"takePicture err");
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    while (camera.mediaBusy) {
        NSLog(@"media busy");
        [NSThread sleepForTimeInterval:0.5f];
    }
    [camera setCameraPropertyValue:@"EXPREV" value:@"<EXPREV/0.0>" error:nil];
    [camera unlockAutoFocus:nil];
    [camera unlockAutoExposure:nil];
}

@end
