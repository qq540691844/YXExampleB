//
//  ViewController.m
//  test
//
//  Created by admin on 2017/9/11.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "YXExampleBViewController.h"
#import "WHBle.h"
#import "WHBluetooehVc.h"

@interface YXExampleBViewController ()<UITableViewDelegate,UITableViewDataSource,WHBleSearchDelegate>

@property (nonatomic,strong)WHBle *ble;

@property (nonatomic,strong) NSMutableArray *dataArrary;

@property (nonatomic,strong) UITableView *tableview;

@end

@implementation YXExampleBViewController

-(NSMutableArray *)dataArrary
{
    if (!_dataArrary) {
        _dataArrary=[NSMutableArray array];
    }
    return _dataArrary;
}

-(UITableView *)tableview
{
    if (!_tableview) {
        _tableview=[[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableview.delegate=self;
        _tableview.dataSource=self;
        _tableview.rowHeight=50;
        
        
    }
    
    return _tableview;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.tableview];
    
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"停止" style:UIBarButtonItemStylePlain target:self action:@selector(stopSearch)];
    
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"搜索" style:UIBarButtonItemStylePlain target:self action:@selector(search)];
    
    _ble=[WHBle shareWHBle];
    _ble.searchDelegate=self;
    [_ble bleInit];
    
    [self search];
    
    //    NSString *string = @"A";
    //    int asciiCode = [string characterAtIndex:0];
    //
    //    DebugLog(@"------%d",asciiCode);
    //
    //    NSString *str=[self ToHex:15];
    //    DebugLog(@"------%@",str);
}




-(void)stopSearch
{
    [_ble stopSearch];
}

-(void)search
{
    [self.dataArrary removeAllObjects];
    
    [_ble scanDevice:4];
    
    //    NSString *str=@"FF99AA550B0100C48006E21234567810";
    //
    //    NSData *data=[self hexToBytesWithStr:str];
    //
    //    NSLog(@"---%@",data);
    
    
    //    WHBluetooehVc *vc=[[WHBluetooehVc alloc] init];
    //    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark UITableviewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArrary.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    
    NSDictionary *dict=_dataArrary[indexPath.row];
    CBPeripheral *per=dict[@"peripheral"];
    
    cell.textLabel.text=per.name;
    cell.detailTextLabel.text=[NSString stringWithFormat:@"%@",dict[@"RSSI"]];
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableviewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self stopSearch];
    NSDictionary *dict=_dataArrary[indexPath.row];
    CBPeripheral *per=dict[@"peripheral"];
    
    
    WHBluetooehVc *vc=[[WHBluetooehVc alloc] init];
    vc.per=per;
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark WHBleSearchDelegate
//扫描回调
-(void)bleDidDiscoverPeripherals:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    
    if (peripheral.name.length <= 0) {
        
        return ;
        
    }
    DebugLog(@"Discovered name:%@,identifier:%@,advertisementData:%@,RSSI:%@", peripheral.name, peripheral.identifier,advertisementData,RSSI);
    
    if (self.dataArrary.count == 0) {
        
        NSDictionary *dict = @{@"peripheral":peripheral, @"RSSI":RSSI};
        [self.dataArrary addObject:dict];
        
    } else {
        
        BOOL isExist = NO;
        for (int i = 0; i < self.dataArrary.count; i++) {
            
            NSDictionary *dict = [self.dataArrary objectAtIndex:i];
            CBPeripheral *per = dict[@"peripheral"];
            
            if ([per.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
                
                isExist = YES;
                NSDictionary *dict = @{@"peripheral":peripheral, @"RSSI":RSSI};
                [_dataArrary replaceObjectAtIndex:i withObject:dict];
            }
        }
        
        if (!isExist) {
            
            NSDictionary *dict = @{@"peripheral":peripheral, @"RSSI":RSSI};
            
            [self.dataArrary addObject:dict];
        }
    }
    [self.tableview reloadData];
    
    
}





@end
