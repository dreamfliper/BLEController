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

//@interface RBL_ServiceViewController ()
//
//@end

@implementation RBL_ServiceViewController
@synthesize ble;

- (void)viewDidLoad {
    [super viewDidLoad];
    ble.delegate = self;
    uuid_service = [CBUUID UUIDWithString:@"FAB0"];
    uuid_char = [CBUUID UUIDWithString:@"FAB1"];
    uuid_char_noti = [CBUUID UUIDWithString:@"FAB2"];
    for (int i = 0; i<(256+512); i++){
        content[i] = i;
    }

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)Uploadbutton:(id)sender{
//    char cData = 0x07;
//    unsigned char content[256+512];
//    unsigned char commandOne[20] = {0x06,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0,0,0,0,0,0,0,0,0,0,0}
//                 ,commandTwo[20] = {0x00,0x03,0x00,0x00,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    
//    for (int i = 0; i<256; i++)
//        matadata[i] = i;
//    
//    for (int i = 0; i<512; i++)
//        content[i] = i;

//    NSLog(@"%d,%d",matadata[3],content[55]);
//    NSData* nsData1=[NSData dataWithBytes:commandOne length:sizeof(commandOne)];
//    
//    NSData* nsData3=[NSData dataWithBytes:matadata length:sizeof(matadata)];
//    NSData* nsData4=[NSData dataWithBytes:content length:sizeof(content)];
//    nsData1 = [self charToNSData:matadata];
//    NSLog(@"%@",nsData1);
//    [ble writeValue:uuid_service characteristicUUID:uuid_char p:ble.activePeripheral data:nsData1];
//    [ble readValue:uuid_service characteristicUUID:uuid_char p:ble.activePeripheral];
//    [ble notification:uuid_service characteristicUUID:uuid_char_noti p:ble.activePeripheral on:YES];
    
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)SetpOnebutton:(id)sender{
    unsigned char commandOne[20] = {0x06,0x01,0x02,0x03,0x04,0x05,0x06,0,0,0,0,0,0,0,0,0,0,0,0,0};
    NSData* nsData2=[NSData dataWithBytes:commandOne length:sizeof(commandOne)];
    [ble writeValue:uuid_service characteristicUUID:uuid_char p:ble.activePeripheral data:nsData2];
    [ble notification:uuid_service characteristicUUID:uuid_char_noti p:ble.activePeripheral on:YES];

    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)SetpTwobutton:(id)sender{
    unsigned char commandTwo[20] = {0x00,0x00,0x00,0x03,0x00,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    NSData* nsData2=[NSData dataWithBytes:commandTwo length:sizeof(commandTwo)];
    [ble writeValue:uuid_service characteristicUUID:uuid_char p:ble.activePeripheral data:nsData2];
    
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)SetpThreebutton:(id)sender{
    unsigned char firstPayload[20] ;
    memcpy(firstPayload, content, 20);
    serialnumber = 1;
    NSData* nsData2=[NSData dataWithBytes:firstPayload length:sizeof(firstPayload)];
    [ble writeValue:uuid_service characteristicUUID:uuid_char p:ble.activePeripheral data:nsData2];
    flag = YES;
    
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)ShowContentbutton:(id)sender{
    
    [ble readValue:uuid_service characteristicUUID:uuid_char p:ble.activePeripheral];
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
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

-(NSData *)charToNSData:(unsigned char *)tobeNSData
{
    NSData* nsData1=[NSData dataWithBytes:tobeNSData length:sizeof(tobeNSData)];
    NSLog(@"%d,%@",tobeNSData[55],nsData1);
    return nsData1;
}

@end
