//
//  RBL_ServiceViewController.m
//  BLEController
//
//  Created by Henpai Hsu on 2015/1/3.
//  Copyright (c) 2015年 RedBearLab. All rights reserved.
//

#import "RBL_ServiceViewController.h"
#import "RBLMainViewController.h"
#import "RBLControlViewController.h"
#import "RBLDetailViewController.h"

@interface RBL_ServiceViewController ()

@end

@implementation RBL_ServiceViewController
@synthesize ble,UUIDtemp;

- (void)viewDidLoad {
    [super viewDidLoad];
    ble.delegate = self;
    uuid_service = [CBUUID UUIDWithString:@"FAB0"];
    uuid_char = [CBUUID UUIDWithString:@"FAB1"];
    uuid_char_noti = [CBUUID UUIDWithString:@"FAB2"];
    for (int i = 0; i<(256+512); i++){
        content[i] = i;
    }
    
    NSString *RSSInumber = [[NSString alloc] initWithFormat:@"NA"];
    self.Rssi1.text = RSSInumber;
    self.Rssi3.text = RSSInumber;
    self.Rssi5.text = RSSInumber;
    RssiCounter = 0;
    tempRssi = 0;
    // Do any additional setup after loading the view.
    //NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%@",UUIDtemp);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)setValueToServiceControlView
{
    unsigned char *cData;
    NSData* nsData=_BleToSCV;
    cData = malloc([nsData length]);
    [nsData getBytes:cData];
    printf("%s",cData);
    NSLog(@"%@",_BleToSCV);
}

-(void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
    NSLog(@"->DidReceiveData");
    NSData *dataData = [NSData dataWithBytes:data length:sizeof(data)];
    NSLog(@"%@",dataData);
   
}

-(void) bleDidWriteData
{
    if (flag == YES && ((serialnumber*18) < (256 + 512))) {
        unsigned char restPayload[20];
        memcpy(&restPayload[2], &content[serialnumber * 18], 18);
        restPayload[0] = serialnumber >> 8;
        restPayload[1] = serialnumber;
        serialnumber++ ;
        NSData* nsData2=[NSData dataWithBytes:restPayload length:sizeof(restPayload)];
        [ble writeValue:uuid_service characteristicUUID:uuid_char p:ble.activePeripheral data:nsData2];
        NSLog(@"Write %@",nsData2);
        printf("%d",serialnumber);
    }
}

-(void) bleDidUpdateRSSI:(NSNumber *) rssi;
{
    NSString *RSSInumber = [[NSString alloc] initWithFormat:@"%@",rssi];
    NSLog(@"RSSI:%@",rssi);
    self.Rssi1.text = RSSInumber;
    RssiCounter++;
    tempfortemp3 += [rssi intValue];
    tempfortemp5 += [rssi intValue];

    if (RssiCounter % 3 == 0)
    {
        tempRssi = [NSNumber numberWithInt:tempfortemp3 / 3];
        self.Rssi3.text = [tempRssi stringValue];
        tempfortemp3 =0;
    }
    
    if (RssiCounter % 5 == 0)
    {
        tempRssi = [NSNumber numberWithInt:tempfortemp5 / 5];
        self.Rssi5.text = [tempRssi stringValue];
        tempfortemp5 =0;
    }
    
    [ble readRSSI];
}
-(NSData *)charToNSData:(unsigned char *)tobeNSData
{
    NSData* nsData1=[NSData dataWithBytes:tobeNSData length:sizeof(tobeNSData)];
    NSLog(@"%d,%@",tobeNSData[55],nsData1);
    return nsData1;
}
- (IBAction)ScanRssi:(id)sender {
    [ble readRSSI];
}
- (IBAction)ScanWithoutConnection:(id)sender {
//    UUIDtemp = ble.activePeripheral.identifier;
    [ble.CM cancelPeripheralConnection:ble.activePeripheral];
}
-(void) bleDidDisconnect
{
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(StartScanPeripheral) userInfo:nil repeats:NO];
    NSLog(@"did disconnect enter");
}
-(void) bleDidDiscover:(NSNumber *) RSSI UUID:(NSUUID *)UUID;
{
    if ([UUIDtemp isEqualToString:UUID.UUIDString] == TRUE) {
        NSString *RSSInumber = [[NSString alloc] initWithFormat:@"%@",RSSI];
        NSLog(@"RSSI:%@",RSSI);
        self.Rssi1.text = RSSInumber;
        RssiCounter++;
        tempfortemp3 += [RSSI intValue];
        tempfortemp5 += [RSSI intValue];
        
        if (RssiCounter % 3 == 0)
        {
            tempRssi = [NSNumber numberWithInt:tempfortemp3 / 3];
            self.Rssi3.text = [tempRssi stringValue];
            tempfortemp3 =0;
        }
        
        if (RssiCounter % 5 == 0)
        {
            tempRssi = [NSNumber numberWithInt:tempfortemp5 / 5];
            self.Rssi5.text = [tempRssi stringValue];
            tempfortemp5 =0;
        }

    }
}

- (void)StartScanPeripheral
{
    [ble.CM scanForPeripheralsWithServices:nil/*[NSArray arrayWithObject:[CBUUID UUIDWithString:@"FFF0"]]*/ options:nil];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(StopScan) userInfo:nil repeats:NO];
    NSLog(@"Enter Start Scan");
}
-(void)StopScan
{
    [ble.CM stopScan];
    [self StartScanPeripheral];
//    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(StartScanPeripheral) userInfo:nil repeats:NO];
}

- (BOOL) UUIDSAreEqual:(NSUUID *)UUID1 UUID2:(NSUUID *)UUID2
{
    if ([UUID1.UUIDString isEqualToString:UUID2.UUIDString])
        return TRUE;
    else
        return FALSE;
}


@end
