//
//  LiveView.swift
//  RecCameraSwift
//
//  Created by haruhito on 2015/04/12.
//  Copyright (c) 2015年 FromF. All rights reserved.
//

import UIKit

class LiveView: UIViewController , OLYCameraLiveViewDelegate {
    @IBOutlet weak var liveViewImage: UIImageView!
    
    //AppDelegate instance
    var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //Notification Regist
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "NotificationApplicationBackground:", name: appDelegate.NotificationApplicationBackground as String, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "NotificationCameraKitDisconnect:", name: appDelegate.NotificationCameraKitDisconnect as String, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "NotificationRechabilityDisconnect:", name: appDelegate.NotificationNetworkDisconnected as String, object: nil)

        var camera = AppDelegate.sharedCamera
        camera.liveViewDelegate = self

        camera.connect(OLYCameraConnectionTypeWiFi, error: nil)
        
        if (camera.connected) {
            camera.changeRunMode(OLYCameraRunModeRecording, error: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        var camera = AppDelegate.sharedCamera
        camera.disconnectWithPowerOff(false, error: nil)
    }
    
    // MARK: - Button Action
    @IBAction func shutterButtonAction(sender: AnyObject) {
        var camera = AppDelegate.sharedCamera
        
        camera.takePicture(nil, progressHandler: nil, completionHandler: nil, errorHandler: nil)    
    }
    
    // MARK: - LiveView Update
    func camera(camera: OLYCamera!, didUpdateLiveView data: NSData!, metadata: [NSObject : AnyObject]!) {
        var image : UIImage = OLYCameraConvertDataToImage(data,metadata)
        self.liveViewImage.image = image
    }
    
    // MARK: - Notification
    func NotificationApplicationBackground(notification : NSNotification?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func NotificationCameraKitDisconnect(notification : NSNotification?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func NotificationRechabilityDisconnect(notification : NSNotification?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
