//
//  ViewController.swift
//  BluetoothSmartTestSwift
//
//  Created by haruhito on 2015/04/03.
//  Copyright (c) 2015年 FromF. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController , CBCentralManagerDelegate {

    @IBOutlet weak var infoLabel: UILabel!
    //CoreBluetooth
    var centralManager: CBCentralManager!

    //AppDelegate instance
    var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.infoLabel.text = ""
        
        //Notification Regist
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "bluetoothSmartUpdated:", name: appDelegate.BluetoothSmartNotification, object: nil)
        
        //CoreBluetooth Initialize
        var option : NSDictionary = [CBCentralManagerOptionShowPowerAlertKey : true]
        self.centralManager = CBCentralManager(delegate: self, queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) , options: option)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

// MARK: - Button Action
    @IBAction func GetBluetoothSmartParingInfomationAction(sender: AnyObject) {
        OACentralConfiguration.requestConfigurationURL("BluetoothSmartTestSwift.OlympusCameraKit.FromF.github.com")
    }

    @IBAction func PowerOnTestAction(sender: AnyObject) {
        var camera = AppDelegate.sharedCamera
        var result : Bool = true
        
        if (result) {
            result = self.scanBluetoothSmart()
        }
        
        if (result) {
            result = camera.wakeup(nil);
        }
        println("result \(result)")
    }
    
    @IBAction func TakePictureAction(sender: AnyObject) {
        var camera = AppDelegate.sharedCamera
        var result : Bool = true
        
        if (result) {
            result = self.scanBluetoothSmart()
        }
        
        if (result) {
            result = camera.connect(OLYCameraConnectionTypeBluetoothLE, error: nil)
        }
        if ((result) & (camera.connected)) {
            result = camera.changeRunMode(OLYCameraRunModeRecording, error: nil)
        }
        if ((result) & (camera.connected)) {
            camera.takePicture(nil, progressHandler: nil, completionHandler: nil, errorHandler: nil)
        }
        if ((result) & (camera.connected)) {
            camera.disconnectWithPowerOff(true, error: nil)
        }
        println("result \(result)")
    }
    
// MARK: - Notification
    func bluetoothSmartUpdated(notification : NSNotification?) {
        self.infoLabel.text = "Name[\(appDelegate.BluetoothSmartName)] Passcode[\(appDelegate.BluetoothSmartPasscode)]"
    }
    
// MARK: - BluetoothSmart Scan
    func scanBluetoothSmart() ->Bool {
        var result : Bool = true
        
        if (self.centralManager.state != CBCentralManagerState.PoweredOn) {
            println("BluetoothSmart device is not powered on!")
            result = false
        }
        
        if (result) {
            dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                var camera = AppDelegate.sharedCamera
                camera.bluetoothPeripheral = nil
                
                self.centralManager.stopScan()
                //NSDictionary *option = @{ CBCentralManagerScanOptionAllowDuplicatesKey: @NO };
                var option : NSDictionary = [CBCentralManagerScanOptionAllowDuplicatesKey : false]
                self.centralManager.scanForPeripheralsWithServices(OLYCamera.bluetoothServices(), options: nil)
                //10sec wait
                NSThread.sleepForTimeInterval(10.0)
                if (camera.bluetoothPeripheral != nil) {
                    self.centralManager.connectPeripheral(camera.bluetoothPeripheral, options: nil)
                    //2sec wait
                    NSThread.sleepForTimeInterval(2.0)
                    if (camera.bluetoothPeripheral.state != CBPeripheralState.Connected) {
                        println("BluetoothSmart device is not conneted.")
                        camera.bluetoothPeripheral = nil
                    }
                } else {
                    println("BluetoothSmart device is not found.")
                }
            })
            //Check Result
            var camera = AppDelegate.sharedCamera
            if (camera.bluetoothPeripheral == nil) {
                result = false
            }
        }
        
        if (result) {
            var camera = AppDelegate.sharedCamera
            camera.bluetoothPassword = appDelegate.BluetoothSmartPasscode
        }
        
        return result;
    }
    
// MARK: - CBCentralManagerDelegate
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        //NONE
    }

    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        println("peripheral: \(peripheral)")
        
        var camera = AppDelegate.sharedCamera
        if (appDelegate.BluetoothSmartName.length > 0) {
            if (advertisementData[CBAdvertisementDataLocalNameKey] as NSString == appDelegate.BluetoothSmartName) {
                //Store peripheral infomation
                camera.bluetoothPeripheral = peripheral;
                //peripheral scan stop
                centralManager.stopScan()
            }
        }
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        println("BluetoothSmart: connected to peripheral(\(peripheral.name))")
    }
}

