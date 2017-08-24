
/*
 
 Copyright (c) 2013-2014 RedBearLab
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "RBLDetailViewController.h"
#import "RBLMainViewController.h"
#import "RBLControlViewController.h"
#import "RBL_ServiceViewController.h"
#import "Debuglog.h"

@implementation RBLDetailViewController

@synthesize BLEDevicesRssi;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(ReScanbutton:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.refreshControl];
    self.BLEDevicesRssi = [NSMutableArray arrayWithArray:ble.peripheralsRssi];
    for (int i = 0; i<10; i++) {
        RSSiCounter[i]=0;
        tempforp5c[i]=0;
    }
}

-(void) connectionTimer:(NSTimer *)timer
{
    [self.BLEDevices removeAllObjects];
    [self.BLEDevicesRssi removeAllObjects];
    [self.BLEDevicesName removeAllObjects];
    
    if (ble.peripherals.count > 0)
    {
        for (int i = 0; i < ble.peripherals.count; i++)
        {
            CBPeripheral *p = [ble.peripherals objectAtIndex:i];
            NSNumber *n = [ble.peripheralsRssi objectAtIndex:i];
            NSString *name = [[ble.peripherals objectAtIndex:i] name];
            
            if (p.UUID != NULL)
            {
                [self.BLEDevices insertObject:[self getUUIDString:p.UUID] atIndex:i];
                [self.BLEDevicesRssi insertObject:n atIndex:i];
                [RssiP5 insertObject:n  atIndex:i];
                
                if (name != nil)
                {
                    [self.BLEDevicesName insertObject:name atIndex:i];
                }
                else
                {
                    [self.BLEDevicesName insertObject:@"RedBear Device" atIndex:i];
                }
            }
            else
            {
                [self.BLEDevices insertObject:@"NULL" atIndex:i];
                [self.BLEDevicesRssi insertObject:0 atIndex:i];
                [RssiP5 insertObject:n  atIndex:i];
                [self.BLEDevicesName insertObject:@"RedBear Device" atIndex:i];
            }
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"No BLE Device(s) found."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"self" ascending:YES];
    [self.BLEDevicesName sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
    NSLog(@"%@",self.BLEDevicesName);
}

- (void)RSSItimer:(NSTimer *)timer
{
    [self.BLEDevicesRssi removeAllObjects];
    if (ble.peripherals.count > 0)
    {
        for (int i = 0; i < ble.peripherals.count; i++)
        {
            CBPeripheral *p = [ble.peripherals objectAtIndex:i];
            NSNumber *n = [ble.peripheralsRssi objectAtIndex:i];
            NSString *name = [[ble.peripherals objectAtIndex:i] name];
            
            if (p.UUID != NULL)
            {
                [self.BLEDevicesRssi insertObject:n atIndex:i];
                [RssiP5 insertObject:n  atIndex:i];
            }
            else
            {
                [self.BLEDevicesRssi insertObject:0 atIndex:i];
                [RssiP5 insertObject:n  atIndex:i];
            }
        }
    }
    
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
    printf("%d",self.refreshControl.refreshing);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@synthesize ble;

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.BLEDevices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *tableIdentifier = @"cell_uuid";
    CellUuid *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    UIFont *newFont = [UIFont fontWithName:@"Arial" size:13.5];

    cell.lblUuid.font = newFont;
    cell.lblUuid.text = [self.BLEDevices objectAtIndex:indexPath.row];
    
//    newFont = [UIFont fontWithName:@"Arial" size:11.0];
//    cell.lblRssi.font = newFont;
//    NSMutableString *rssiString = [NSMutableString stringWithFormat:@"RSSI : %@", [self.BLEDevicesRssi objectAtIndex:indexPath.row]];
//    cell.lblRssi.text = rssiString;
 
    newFont = [UIFont fontWithName:@"Arial" size:13.0];
    cell.lblName.font = newFont;
    cell.lblName.text = [self.BLEDevicesName objectAtIndex:indexPath.row];
    
//  update the RSSI part of cell immediately
//    NSNumber *n = [ble.peripheralsRssi objectAtIndex:indexPath.row];
    newFont = [UIFont fontWithName:@"Arial" size:11.0];
    cell.lblRssi.font = newFont;
    NSMutableString *rssiString = [NSMutableString stringWithFormat:@"RSSI : %@", [ble.peripheralsRssi objectAtIndex:indexPath.row]];
    RSSiCounter[indexPath.row]++;
    tempforp5c[indexPath.row] += [[ble.peripheralsRssi objectAtIndex:indexPath.row] intValue];
    if (RSSiCounter[indexPath.row]/5 == 0) {
        temprssi = [NSNumber numberWithInt:tempforp5c[indexPath.row] / 5];
        cell.p5c.text = [temprssi stringValue];
    }
    cell.lblRssi.text = rssiString;
  
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [ble connectPeripheral:[ble.peripherals objectAtIndex:indexPath.row]];
    UUIDforNext = [ble.peripherals objectAtIndex:indexPath.row];
    //NSLog(@"%@",UUIDforNext.identifier.UUIDString);
    [self performSegueWithIdentifier:@"gotoService" sender:self];
}

-(NSString *)getUUIDString:(CFUUIDRef)ref
{
    NSString *str = [NSString stringWithFormat:@"%@", ref];
    return [[NSString stringWithFormat:@"%@", str] substringWithRange:NSMakeRange(str.length - 36, 36)];
}

- (IBAction)ReScanbutton:(id)sender{
    NSLog(@"Enter button");
    if (ble.activePeripheral)
        if(ble.activePeripheral.state == CBPeripheralStateConnected)
        {
            [[ble CM] cancelPeripheralConnection:[ble activePeripheral]];
            return;
        }
    
    if (ble.peripherals)
        ble.peripherals = nil;
    
    [ble findBLEPeripherals:3];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)3.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];

    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"gotoService"])
    {
        RBL_ServiceViewController *servicepage = [segue destinationViewController];
        servicepage.ble = ble;
        servicepage.UUIDtemp = UUIDforNext.identifier.UUIDString;
        //NSLog(@"%@,%@",UUIDforNext.identifier.UUIDString,servicepage.UUIDtemp);
    }
}



@end
