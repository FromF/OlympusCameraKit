//
//  AppDelegate.swift
//  RecCameraSwift
//
//  Created by haruhito on 2015/04/12.
//  Copyright (c) 2015年 FromF. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate , OLYCameraConnectionDelegate {

    var window: UIWindow?

    var NotificationCameraKitDisconnect : NSString      = "NotificationCameraKitDisconnect"
    var NotificationNetworkConnected : NSString         = "NotificationNetworkConnected"
    var NotificationNetworkDisconnected : NSString      = "NotificationNetworkDisconnected"
    var reachabilityForLocalWiFi : Reachability = Reachability.reachabilityForLocalWiFi()
    
    class var sharedCamera : OLYCamera {
        struct Static {
            static let instance : OLYCamera = OLYCamera()
        }
        return Static.instance
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        var camera = AppDelegate.sharedCamera
        camera.connectionDelegate = self;
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didChangeNetworkReachability:", name: kReachabilityChangedNotification as String, object: nil)
        //Reachability Notication Start
        reachabilityForLocalWiFi.startNotifier()

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        //Reachability Notication Stop
        reachabilityForLocalWiFi.stopNotifier()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        //Reachability Notication Start
        reachabilityForLocalWiFi.startNotifier()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - ConnectionDelegate
    func camera(camera: OLYCamera!, disconnectedByError error: NSError!) {
        //切断通知
        println("OLYCamera Disconnected")
        NSNotificationCenter.defaultCenter().postNotificationName(self.NotificationCameraKitDisconnect as String, object:self)
    }

    // MARK: - Rechability Notification
    func didChangeNetworkReachability(noteObject : Reachability!) {
        var status : Int = self.reachabilityForLocalWiFi.currentReachabilityStatus().value
        
        if (status == ReachableViaWiFi.value) {
            println("Rechability Connected")
            NSNotificationCenter.defaultCenter().postNotificationName(self.NotificationNetworkConnected as String, object:self)
        } else {
            println("Rechability Disconnected")
            NSNotificationCenter.defaultCenter().postNotificationName(self.NotificationNetworkDisconnected as String, object:self)
        }
    }
}

