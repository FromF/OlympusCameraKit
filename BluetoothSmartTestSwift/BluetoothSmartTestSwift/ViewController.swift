//
//  ViewController.swift
//  BluetoothSmartTestSwift
//
//  Created by haruhito on 2015/04/03.
//  Copyright (c) 2015年 FromF. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var infoLabel: UILabel!
    
    //AppDelegate instance
    var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.infoLabel.text = ""
        
        //Notification Regist
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "bluetoothSmartUpdated:", name: appDelegate.BluetoothSmartNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

// MARK: - Button Action
    @IBAction func GetBluetoothSmartParingInfomationAction(sender: AnyObject) {
        OACentralConfiguration.requestConfigurationURL("BluetoothSmartTestSwift.OlympusCameraKit.FromF.github.com")
    }

// MARK: - Notification
    func bluetoothSmartUpdated(notification : NSNotification?) {
        self.infoLabel.text = "Name[\(appDelegate.BluetoothSmartName)] Passcode[\(appDelegate.BluetoothSmartPasscode)]"
    }
}

