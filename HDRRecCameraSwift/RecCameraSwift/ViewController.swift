//
//  ViewController.swift
//  RecCameraSwift
//
//  Created by haruhito on 2015/04/12.
//  Copyright (c) 2015年 FromF. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var connectButton: UIButton!

    //AppDelegate instance
    var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Rechability Notification Regist
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "NotificationNetowork:", name: appDelegate.NotificationNetworkConnected as String, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "NotificationNetowork:", name: appDelegate.NotificationNetworkDisconnected as String, object: nil)
        
        //ConnectButton Update
        connectButtonEnable()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func connectButtonEnable() {
        let status : Int = appDelegate.reachabilityForLocalWiFi.currentReachabilityStatus().value
        
        if (status == ReachableViaWiFi.value) {
            connectButton.enabled = true
        } else {
            connectButton.enabled = false
        }
    }
    
    // MARK: - Notification
    func NotificationNetowork(notification : NSNotification?) {
        //ConnectButton Update
        connectButtonEnable()
    }
}

