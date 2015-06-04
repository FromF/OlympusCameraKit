//
//  ViewController.m
//  BluetoothSmartTest
//
//  Created by haruhito on 2015/03/28.
//  Copyright (c) 2015年 FromF. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
<CBCentralManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
//CoreBluetooth
@property (strong,nonatomic) CBCentralManager *centralManager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.infoLabel.text = @"";
    
    //KVO Regist
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate addObserver:self forKeyPath:@"BletoothSmartName" options:NSKeyValueObservingOptionNew context:nil];
    [delegate addObserver:self forKeyPath:@"BletoothSmartPasscode" options:NSKeyValueObservingOptionNew context:nil];
    
    //CoreBluetooth Initialize
    NSDictionary *option = @{ CBCentralManagerOptionShowPowerAlertKey: @YES};
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) options:option];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Action
- (IBAction)GetBluetoothSmartParingInfomationAction:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [OACentralConfiguration requestConfigurationURL:@"BluetoothSmartTest.OlympusCameraKit.FromF.github.com"];
    });
}
- (IBAction)PowerOnTestAction:(id)sender {
    BOOL result = YES;
    if (result) {
        result = [self scanBluetoothSmart];
    }
    if (result) {
        OLYCamera *camera = AppDelegateCamera();
        result = [camera wakeup:nil];
    }
    NSLog(@"result(%d)",result);
}
- (IBAction)TakePictureAction:(id)sender {
    BOOL result = YES;
    OLYCamera *camera = AppDelegateCamera();
    if (result) {
        result = [self scanBluetoothSmart];
    }
    if (result) {
        result = [camera connect:OLYCameraConnectionTypeBluetoothLE error:nil];
    }
    if ((result) && (camera.connected)) {
        result = [camera changeRunMode:OLYCameraRunModeRecording error:nil];
    }
    if ((result) && (camera.connected)) {
        [camera takePicture:nil progressHandler:nil completionHandler:nil errorHandler:nil];
    }
    if ((result) && (camera.connected)) {
        [camera disconnectWithPowerOff:YES error:nil];
    }
    NSLog(@"result(%d)",result);
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqual:@"BletoothSmartName"] || [keyPath isEqual:@"BletoothSmartPasscode"]) {
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.infoLabel.text = [NSString stringWithFormat:@"Name[%@] Passcode[%@]",delegate.BletoothSmartName,delegate.BletoothSmartPasscode];
    }
}

#pragma mark - BluetoothSmart Scan
-(BOOL)scanBluetoothSmart
{
    BOOL result = YES;
    
    if (result) {
        if (self.centralManager.state != CBCentralManagerStatePoweredOn) {
            NSLog(@"BluetoothSmart device is not powered on!");
            result = NO;
        }
    }
    
    if (result) {
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            OLYCamera *camera = AppDelegateCamera();
            camera.bluetoothPeripheral = nil;
            
            [self.centralManager stopScan];
            NSDictionary *option = @{ CBCentralManagerScanOptionAllowDuplicatesKey: @NO };
            [self.centralManager scanForPeripheralsWithServices:[OLYCamera bluetoothServices] options:option];
            //10sec wait
            [NSThread sleepForTimeInterval:10.0f];
            if (camera.bluetoothPeripheral) {
                [self.centralManager connectPeripheral:camera.bluetoothPeripheral options:nil];
                //10sec wait
                [NSThread sleepForTimeInterval:2.0f];
                //
                if (camera.bluetoothPeripheral.state != CBPeripheralStateConnected) {
                    NSLog(@"BluetoothSmart device is not conneted.");
                    camera.bluetoothPeripheral = nil;
                }
            } else {
                NSLog(@"BluetoothSmart device is not found.");
            }
            
        });
        //Check Result
        OLYCamera *camera = AppDelegateCamera();
        if (!camera.bluetoothPeripheral) {
            result = NO;
        }
    }
    if (result) {
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        OLYCamera *camera = AppDelegateCamera();
        camera.bluetoothPassword = delegate.BletoothSmartPasscode;
    }
    
    return result;
}
#pragma mark - CBCentralManagerDelegate
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    //None
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    OLYCamera *camera = AppDelegateCamera();
    
    if (delegate.BletoothSmartName && delegate.BletoothSmartName.length > 0) {
        if ([[advertisementData objectForKey:CBAdvertisementDataLocalNameKey]isEqualToString:delegate.BletoothSmartName]) {
            //Store peripheral infomation
            camera.bluetoothPeripheral = peripheral;
            //peripheral scan stop
            [self.centralManager stopScan];
        }
    }
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"BluetoothSmart: connected to peripheral(%@)",peripheral.name);
}
@end
