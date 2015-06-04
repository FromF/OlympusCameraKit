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
    var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.infoLabel.text = ""
        
        //Notification Regist
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "bluetoothSmartUpdated:", name: appDelegate.BluetoothSmartNotification as String, object: nil)
        
        //CoreBluetooth Initialize
        var option : NSDictionary = [CBCentralManagerOptionShowPowerAlertKey : true]
        self.centralManager = CBCentralManager(delegate: self, queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) , options: option as [NSObject : AnyObject])
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
        if ((result) && (camera.connected)) {
            result = camera.changeRunMode(OLYCameraRunModeRecording, error: nil)
        }
        if ((result) && (camera.connected)) {
            camera.takePicture(nil, progressHandler: nil, completionHandler: nil, errorHandler: nil)
        }
        if ((result) && (camera.connected)) {
            camera.disconnectWithPowerOff(true, error: nil)
        }
        println("result \(result)")
    }
    
// MARK: - Notification
    func bluetoothSmartUpdated(notification : NSNotification?) {
        dispatch_async(dispatch_get_main_queue(), {
            self.infoLabel.text = "Name[\(self.appDelegate.BluetoothSmartName)] Passcode[\(self.appDelegate.BluetoothSmartPasscode)]"
        })
    }
    
// MARK: - BluetoothSmart Scan
    func scanBluetoothSmart() ->Bool {
        var result : Bool = true
        
        if (result) {
            if (self.centralManager.state != CBCentralManagerState.PoweredOn) {
                println("BluetoothSmart device is not powered on!")
                result = false
            }
        }
        
        if (result) {
            if (appDelegate.BluetoothSmartName.length == 0) {
                println("BluetoothSmart pairing infomation not found!")
                result = false
            }
        }
        
        if (result) {
            dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                var camera = AppDelegate.sharedCamera
                camera.bluetoothPeripheral = nil
                
                self.centralManager.stopScan()
                var option : NSDictionary = [CBCentralManagerScanOptionAllowDuplicatesKey : false]
                self.centralManager.scanForPeripheralsWithServices(OLYCamera.bluetoothServices(), options: nil)
                //10sec timeout
                if (true) {
                    var startdate : NSDate = NSDate()
                    while(true) {
                        if (NSDate().timeIntervalSinceDate(startdate) > 10) {
                            break;
                        }
                        if (camera.bluetoothPeripheral != nil) {
                            break;
                        }
                        NSThread.sleepForTimeInterval(0.2)
                    }
                }
                if (camera.bluetoothPeripheral != nil) {
                    self.centralManager.connectPeripheral(camera.bluetoothPeripheral, options: nil)
                    //2sec timeout
                    if (true) {
                        var startdate : NSDate = NSDate()
                        while(true) {
                            if (NSDate().timeIntervalSinceDate(startdate) > 2) {
                                break;
                            }
                            if (camera.bluetoothPeripheral.state == CBPeripheralState.Connected) {
                                break;
                            }
                            NSThread.sleepForTimeInterval(0.2)
                        }
                    }
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
            camera.bluetoothPassword = appDelegate.BluetoothSmartPasscode as String
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
            if (advertisementData[CBAdvertisementDataLocalNameKey] as! NSString == appDelegate.BluetoothSmartName) {
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

