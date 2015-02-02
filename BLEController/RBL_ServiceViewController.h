//
//  RBL_ServiceViewController.h
//  BLEController
//
//  Created by Henpai Hsu on 2015/1/3.
//  Copyright (c) 2015年 RedBearLab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellUuid.h"
#import "RBLDetailViewController.h"
#import "BLE.h"

@protocol RBL_ServiceViewController <NSObject>

- (void) setValueToServiceControlView;

@end

@interface RBL_ServiceViewController : UIViewController <BLEDelegate>
{
    CBUUID *uuid_service;
    CBUUID *uuid_char;
    CBUUID *uuid_char_noti;
    unsigned char content[256+512];
    int serialnumber;
    BOOL flag;
}
//- (void) didSelected:(NSInteger)selected;

@property (strong, nonatomic) BLE *ble;
@property (nonatomic) NSData* BleToSCV;
@property (nonatomic) id<RBL_ServiceViewController> ServiceView;
@property (nonatomic,strong) UIRefreshControl *reflashControl;

@end



