//
//  LiveView.swift
//  RecCameraSwift
//
//  Created by haruhito on 2015/04/12.
//  Copyright (c) 2015年 FromF. All rights reserved.
//

import UIKit

class LiveView: UIViewController , OLYCameraLiveViewDelegate , OLYCameraRecordingSupportsDelegate {
    @IBOutlet weak var liveViewImage: UIImageView!
    @IBOutlet weak var recviewImage: UIImageView!
    @IBOutlet weak var infomation: UILabel!
    
    //AppDelegate instance
    var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //Notification Regist
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "NotificationApplicationBackground:", name: UIApplicationDidEnterBackgroundNotification , object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "NotificationCameraKitDisconnect:", name: appDelegate.NotificationCameraKitDisconnect as String, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "NotificationRechabilityDisconnect:", name: appDelegate.NotificationNetworkDisconnected as String, object: nil)

        var camera = AppDelegate.sharedCamera
        camera.liveViewDelegate = self
        camera.recordingSupportsDelegate = self

        camera.connect(OLYCameraConnectionTypeWiFi, error: nil)
        
        if (camera.connected) {
            camera.changeRunMode(OLYCameraRunModeRecording, error: nil)
            camera.setCameraPropertyValue("TAKEMODE", value: "<TAKEMODE/P>", error: nil)

            let inquire = camera.inquireHardwareInformation(nil) as NSDictionary
            let modelname = inquire.objectForKey(OLYCameraHardwareInformationCameraModelNameKey) as? String
            let version = inquire.objectForKey(OLYCameraHardwareInformationCameraFirmwareVersionKey) as? String
            infomation.text = modelname! + " Ver." + version!
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
    
    // MARK: - 露出補正
    @IBAction func exprevSlider(sender: AnyObject) {
        let slider = sender as! UISlider
        let index = Int(slider.value + 0.5)
        slider.value = Float(index)
        
        var value = NSString(format: "%+0.1f" , slider.value)
        if (slider.value == 0) {
            value = NSString(format: "%0.1f" , slider.value)
        }
        
        var camera = AppDelegate.sharedCamera
        
        camera.setCameraPropertyValue("EXPREV", value: "<EXPREV/" + (value as String) + ">", error: nil)
    }
    
    // MARK: - LiveView Update
    func camera(camera: OLYCamera!, didUpdateLiveView data: NSData!, metadata: [NSObject : AnyObject]!) {
        var image : UIImage = OLYCameraConvertDataToImage(data,metadata)
        self.liveViewImage.image = image
    }
    
    // MARK: - Recview
    func camera(camera: OLYCamera!, didReceiveCapturedImagePreview data: NSData!, metadata: [NSObject : AnyObject]!) {
        var image : UIImage = OLYCameraConvertDataToImage(data,metadata)
        recviewImage.image = image
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
