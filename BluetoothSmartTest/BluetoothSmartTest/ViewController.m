//
//  ViewController.m
//  BluetoothSmartTest
//
//  Created by haruhito on 2015/03/28.
//  Copyright (c) 2015年 FromF. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Action
- (IBAction)GetBluetoothSmartParingInfomationAction:(id)sender {
    [OACentralConfiguration requestConfigurationURL:@"BluetoothSmartTest.OlympusCameraKit.FromF.github.com"];
}
- (IBAction)PowerOnTestAction:(id)sender {
}
- (IBAction)TakePictureAction:(id)sender {
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqual:@"BletoothSmartName"] || [keyPath isEqual:@"BletoothSmartPasscode"]) {
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.infoLabel.text = [NSString stringWithFormat:@"Name[%@] Passcode[%@]",delegate.BletoothSmartName,delegate.BletoothSmartPasscode];
    }
}

@end
