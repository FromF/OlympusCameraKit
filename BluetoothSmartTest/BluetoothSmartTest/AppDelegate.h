//
//  AppDelegate.h
//  BluetoothSmartTest
//
//  Created by haruhito on 2015/03/28.
//  Copyright (c) 2015年 FromF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OLYCameraKit/OLYCamera.h>
#import <OLYCameraKit/OACentralConfiguration.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *BletoothSmartName;
@property (strong, nonatomic) NSString *BletoothSmartPasscode;

@end

extern OLYCamera *AppDelegateCamera();
