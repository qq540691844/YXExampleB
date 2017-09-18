//
//  WHBluetooehVc.m
//  test
//
//  Created by admin on 2017/9/13.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "WHBluetooehVc.h"
#import "LYSearchItem.h"

@interface WHBluetooehVc ()<WHBleDelegate>

@property (nonatomic,strong)WHBle *ble;

@property (nonatomic,strong) LYSearchItem *IDItem;/**<设备ID*/

@property (nonatomic,strong) LYSearchItem *pwdItem;/**<设备密码*/

@property (nonatomic,strong) LYSearchItem *nPwdItem;/**<设备新密码*/

@property (nonatomic,strong) LYSearchItem *nameItem;/**<设备名称*/

@property (nonatomic,strong) LYSearchItem *disConneItem;/**<设备自动断开时间*/

@property (nonatomic,strong) LYSearchItem *txPowerItem;/**<设备发送功率*/

@property (nonatomic,strong) LYSearchItem *activeTimeItem;/**<设备输出保持时间*/

@property (nonatomic,strong) LYSearchItem *configBitItem;/**<设备配置位*/

@property (nonatomic,strong) LYSearchItem *timeItem;/**<设备时钟信息*/

@property (nonatomic,strong) LYSearchItem *callBackItem;/**<设备请求返回信息*/

@property (nonatomic,strong) UIButton *modifyNameBtn;/**<修改设备名称*/

@property (nonatomic,strong) UIButton *oneKeyOpenDoorBtn;/**<一键开门*/

@property (nonatomic,strong) UIButton *oneKeyOpenDoorTimeBtn;/**<一键开门带关闭时间*/

@property (nonatomic,strong) UIButton *setDateBtn;/**<设置设备时钟年月日*/

@property (nonatomic,strong) UIButton *setTimeBtn;/**<设置设备始终时分秒*/

@property (nonatomic,strong) UIButton *modifyPwdBtn;/**<修改设备密码*/

@property (nonatomic,strong) UIButton *readTimeBtn;/**<读取设备时钟信息*/

@property (nonatomic,strong) UIButton *readConfigBtn;/**<读取设备配置*/

@property (nonatomic,strong) UIButton *configDoorBtn;/**<设置设备配置信息*/

@end

@implementation WHBluetooehVc

-(void)viewWillAppear:(BOOL)animated
{
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.backgroundColor=[UIColor whiteColor];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[WHBle shareWHBle] disConnectDeviece:self.per];
    [[WHBle shareWHBle] disConnectAllDevieces];
    self.ble.delegate=nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.view.backgroundColor=[UIColor whiteColor];
    
    [self creatUI];
    [self layoutConstraint];
    
    self.ble=[WHBle shareWHBle];
    self.ble.delegate=self;
    
    //[[WHBle shareWHBle] connectDeviece:self.per];
    
    
}

-(void)creatUI{
    
    MJWeakSelf
    //设备ID
    self.IDItem=[[LYSearchItem alloc] initWithTitle:@"设备ID"];
    self.IDItem.contentTF.text=[self.per.name substringWithRange:NSMakeRange(2, 8)];
    [self.view addSubview:self.IDItem];
    //设备密码
    self.pwdItem=[[LYSearchItem alloc] initWithTitle:@"设备密码"];
    self.pwdItem.contentTF.text=@"12345678";
    [self.view addSubview:self.pwdItem];
    //设备新密码
    self.nPwdItem=[[LYSearchItem alloc] initWithTitle:@"设备新密码"];
    [self.view addSubview:self.nPwdItem];
    //设备名称
    self.nameItem=[[LYSearchItem alloc] initWithTitle:@"设备名称"];
    self.nameItem.contentTF.text=[self.per.name substringWithRange:NSMakeRange(self.per.name.length-4, 4)];
    [self.view addSubview:self.nameItem];
    
    //设备配置,自动断开时间
    self.disConneItem=[[LYSearchItem alloc] initWithPlaceholder:@"disConne"];
    [self.view addSubview:self.disConneItem];
    //蓝牙发送功率
    self.txPowerItem=[[LYSearchItem alloc] initWithPlaceholder:@"txPower"];
    [self.view addSubview:self.txPowerItem];
    //蓝牙输出保持时间
    self.activeTimeItem=[[LYSearchItem alloc] initWithPlaceholder:@"activeTime"];
    [self.view addSubview:self.activeTimeItem];
    //配置位
    self.configBitItem=[[LYSearchItem alloc] initWithPlaceholder:@"configBit"];
    [self.view addSubview:self.configBitItem];
    
    //设备时钟信息
    self.timeItem=[[LYSearchItem alloc] initWithPlaceholder:@"年/月/日/时/分/秒"];
    [self.view addSubview:self.timeItem];
    //设备发出请求的返回值
    self.callBackItem=[[LYSearchItem alloc] initWithPlaceholder:@"回调函数返回值"];
    [self.view addSubview:self.callBackItem];
    //修改设备名称
    self.modifyNameBtn=[self.view addBackgroundButtonWithTitle:@"修改名称" font:[UIFont systemFontOfSize:15] titleColor:[UIColor blackColor] backgroundColor:[UIColor grayColor] imageName:@"" corner:0 boderWide:0.5 boderColor:[UIColor blackColor] action:^(UIButton *button) {
        
        [[WHBle shareWHBle] oneKeyChangeDevName:weakSelf.per password:weakSelf.pwdItem.contentTF.text newDevieceName:weakSelf.nameItem.contentTF.text];
        
    }];
    //一键开门
    self.oneKeyOpenDoorBtn=[self.view addBackgroundButtonWithTitle:@"一键开锁" font:[UIFont systemFontOfSize:15] titleColor:[UIColor blackColor] backgroundColor:[UIColor grayColor] imageName:@"" corner:0 boderWide:0.5 boderColor:[UIColor blackColor] action:^(UIButton *button) {
        
        [[WHBle shareWHBle] oneKeyOpenDevice:weakSelf.per password:weakSelf.pwdItem.contentTF.text];
        
        
    }];
    //一键开锁 延时5秒
    self.oneKeyOpenDoorTimeBtn=[self.view addBackgroundButtonWithTitle:@"一键开锁 延时5秒" font:[UIFont systemFontOfSize:15] titleColor:[UIColor blackColor] backgroundColor:[UIColor grayColor] imageName:@"" corner:0 boderWide:0.5 boderColor:[UIColor blackColor] action:^(UIButton *button) {
        
        [[WHBle shareWHBle] oneKeyOpenDevice:weakSelf.per password:weakSelf.pwdItem.contentTF.text withTime:5];
        
        
    }];
    
    //设置时间年月日
    self.setDateBtn=[self.view addBackgroundButtonWithTitle:@"设置时间年月日" font:[UIFont systemFontOfSize:15] titleColor:[UIColor blackColor] backgroundColor:[UIColor grayColor] imageName:@"" corner:0 boderWide:0.5 boderColor:[UIColor blackColor] action:^(UIButton *button) {
        
        
    }];
    //设置时间时分秒
    self.setTimeBtn=[self.view addBackgroundButtonWithTitle:@"设置时间时分秒" font:[UIFont systemFontOfSize:15] titleColor:[UIColor blackColor] backgroundColor:[UIColor grayColor] imageName:@"" corner:0 boderWide:0.5 boderColor:[UIColor blackColor] action:^(UIButton *button) {
        
        
    }];

    //修改密码
    self.modifyPwdBtn=[self.view addBackgroundButtonWithTitle:@"修改密码" font:[UIFont systemFontOfSize:15] titleColor:[UIColor blackColor] backgroundColor:[UIColor grayColor] imageName:@"" corner:0 boderWide:0.5 boderColor:[UIColor blackColor] action:^(UIButton *button) {
        
        [[WHBle shareWHBle] oneKeyChangeDevPsw:weakSelf.per password:weakSelf.pwdItem.contentTF.text newPassword:weakSelf.nPwdItem.contentTF.text];
        
        
    }];
    //读取配置
    self.readConfigBtn=[self.view addBackgroundButtonWithTitle:@"读取配置" font:[UIFont systemFontOfSize:15] titleColor:[UIColor blackColor] backgroundColor:[UIColor grayColor] imageName:@"" corner:0 boderWide:0.5 boderColor:[UIColor blackColor] action:^(UIButton *button) {
        
        [[WHBle shareWHBle] oneKeyReadDeviceConfigInfo:weakSelf.per password:weakSelf.pwdItem.contentTF.text];
        
    }];
    
    //读取时钟
    self.readTimeBtn=[self.view addBackgroundButtonWithTitle:@"读取时钟" font:[UIFont systemFontOfSize:15] titleColor:[UIColor blackColor] backgroundColor:[UIColor grayColor] imageName:@"" corner:0 boderWide:0.5 boderColor:[UIColor blackColor] action:^(UIButton *button) {
        
        [[WHBle shareWHBle] oneKeyReadClock:weakSelf.per password:weakSelf.pwdItem.contentTF.text];
        
        
    }];
    
    //配置门禁
    self.configDoorBtn=[self.view addBackgroundButtonWithTitle:@"配置门禁" font:[UIFont systemFontOfSize:15] titleColor:[UIColor blackColor] backgroundColor:[UIColor grayColor] imageName:@"" corner:0 boderWide:0.5 boderColor:[UIColor blackColor] action:^(UIButton *button) {
        
        [[WHBle shareWHBle] oneKeySetDeviceConfigInfo:weakSelf.per password:weakSelf.pwdItem.contentTF.text disConnectTime:[weakSelf.disConneItem.contentTF.text intValue] txPower:[weakSelf.txPowerItem.contentTF.text intValue] activeTime:[weakSelf.activeTimeItem.contentTF.text intValue] configBit:[weakSelf.configBitItem.contentTF.text intValue]];
        
        
    }];
    

    
    
    
    

}

-(void)layoutConstraint{
    //设备ID
    [self.IDItem mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(self.view.mas_left);
        make.top.mas_equalTo(self.view.mas_top).offset(5);
        make.width.mas_equalTo(self.view.mas_width).multipliedBy(0.5);
        make.height.mas_equalTo(@20);
        
    }];
    //设备密码
    [self.pwdItem mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(self.IDItem.mas_right);
        make.top.mas_equalTo(self.view.mas_top).offset(5);
        make.width.mas_equalTo(self.view.mas_width).multipliedBy(0.5);
        make.height.mas_equalTo(@20);
        
    }];
    //设备新密码
    [self.nPwdItem mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(self.view.mas_left);
        make.top.mas_equalTo(self.IDItem.mas_bottom).offset(10);
        make.width.mas_equalTo(self.view.mas_width).multipliedBy(0.5);
        make.height.mas_equalTo(@20);
        
    }];
    //设备名称
    [self.nameItem mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(self.nPwdItem.mas_right);
        make.top.mas_equalTo(self.pwdItem.mas_bottom).offset(10);
        make.width.mas_equalTo(self.view.mas_width).multipliedBy(0.5);
        make.height.mas_equalTo(@20);
        
    }];
    //设备自动断开时间
    [self.disConneItem mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(@30);
        make.top.mas_equalTo(self.nPwdItem.mas_bottom).offset(10);
        make.width.mas_equalTo(self.view.mas_width).multipliedBy(0.2);
        make.height.mas_equalTo(@20);
        
    }];
    //设备发送功率
    [self.txPowerItem mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(self.disConneItem.mas_right).offset(4);
        make.top.mas_equalTo(self.disConneItem);
        make.width.mas_equalTo(self.view.mas_width).multipliedBy(0.2);
        make.height.mas_equalTo(@20);
        
    }];
    //设备输出保持时间
    [self.activeTimeItem mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(self.txPowerItem.mas_right).offset(4);
        make.top.mas_equalTo(self.disConneItem);
        make.width.mas_equalTo(self.view.mas_width).multipliedBy(0.2);
        make.height.mas_equalTo(@20);
        
    }];
    //设备配置位
    [self.configBitItem mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(self.activeTimeItem.mas_right).offset(4);
        make.top.mas_equalTo(self.disConneItem);
        make.width.mas_equalTo(self.view.mas_width).multipliedBy(0.2);
        make.height.mas_equalTo(@20);
        
    }];

    //设备时钟
    [self.timeItem mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(self.view);
        make.top.mas_equalTo(self.disConneItem.mas_bottom).offset(10);
        make.width.mas_equalTo(self.view.mas_width);
        make.height.mas_equalTo(@30);
        
    }];
    //设备请求返回信息
    [self.callBackItem mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(self.view);
        make.top.mas_equalTo(self.timeItem.mas_bottom).offset(10);
        make.width.mas_equalTo(self.view.mas_width);
        make.height.mas_equalTo(@30);
        
    }];
    //选择门禁
    [self.modifyNameBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.callBackItem.mas_bottom).offset(20);
        make.width.mas_equalTo(self.view.mas_width).multipliedBy(0.95);
        make.height.mas_equalTo(@40);
        
    }];
    //一键开门
    [self.oneKeyOpenDoorBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(self.view).offset(10);
        make.top.mas_equalTo(self.modifyNameBtn.mas_bottom).offset(10);
        make.width.mas_equalTo(self.view.mas_width).multipliedBy(0.46);
        make.height.mas_equalTo(@40);
        
    }];
    //一键开门带关闭时间
    [self.oneKeyOpenDoorTimeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.mas_equalTo(self.view).offset(-10);
        make.top.mas_equalTo(self.modifyNameBtn.mas_bottom).offset(10);
        make.width.mas_equalTo(self.view.mas_width).multipliedBy(0.46);
        make.height.mas_equalTo(@40);
        
    }];
    //设置设备时钟年月日
    [self.setDateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(self.view).offset(10);
        make.top.mas_equalTo(self.oneKeyOpenDoorBtn.mas_bottom).offset(10);
        make.width.mas_equalTo(self.view.mas_width).multipliedBy(0.46);
        make.height.mas_equalTo(@40);
        
    }];
    //设置时钟时分秒
    [self.setTimeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.mas_equalTo(self.view).offset(-10);
        make.top.mas_equalTo(self.oneKeyOpenDoorBtn.mas_bottom).offset(10);
        make.width.mas_equalTo(self.view.mas_width).multipliedBy(0.46);
        make.height.mas_equalTo(@40);
        
    }];
    //修改设备密码
    [self.modifyPwdBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(self.view).offset(10);
        make.top.mas_equalTo(self.setDateBtn.mas_bottom).offset(10);
        make.width.mas_equalTo(self.view.mas_width).multipliedBy(0.46);
        make.height.mas_equalTo(@40);
        
    }];
    //读取设备时钟
    [self.readTimeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.mas_equalTo(self.view).offset(-10);
        make.top.mas_equalTo(self.setDateBtn.mas_bottom).offset(10);
        make.width.mas_equalTo(self.view.mas_width).multipliedBy(0.46);
        make.height.mas_equalTo(@40);
        
    }];
    //读取设备配置信息
    [self.readConfigBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(self.view).offset(10);
        make.top.mas_equalTo(self.modifyPwdBtn.mas_bottom).offset(10);
        make.width.mas_equalTo(self.view.mas_width).multipliedBy(0.46);
        make.height.mas_equalTo(@40);
        
    }];
    //设置配置信息
    [self.configDoorBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.mas_equalTo(self.view).offset(-10);
        make.top.mas_equalTo(self.modifyPwdBtn.mas_bottom).offset(10);
        make.width.mas_equalTo(self.view.mas_width).multipliedBy(0.46);
        make.height.mas_equalTo(@40);
        
    }];



}

#pragma mark WHBleDelegate

//连接设备回调
-(void)bleDidConnectPeripheral:(CBPeripheral *)peripheral status:(ConnectStatus)status
{
    DebugLog(@"--peripheral:%@--status:%ld",peripheral.name,(unsigned long)status);
    
    if (status == CONNECT_FAILED) {
        DebugLog(@"连接设备失败");
    }else if (status == CONNECT_SUCCESSED) {
        DebugLog(@"连接设备成功");
    }else{
        DebugLog(@"未知错误");
    }
    
}
//一键开门回调
-(void)oneKeyOpenDeviceCallBack:(WHBleResultType)result{
    DebugLog(@"oneKeyOpenDeviceCallBack:%d",result);
    
    self.callBackItem.contentTF.text=[NSString stringWithFormat:@"%d",result];
    [self.callBackItem setNeedsDisplay];
}
//读取配置信息回调
-(void)oneKeyReadDeviceConfigInfoCallBack:(WHBleResultType)result disConnectTime:(int)disConnectTime txPower:(WHBleTxPowerType)power activeTime:(int)actTime configBit:(int)configBit{
    DebugLog(@"oneKeyReadDeviceConfigInfoCallBack:%d",result);
    
    self.callBackItem.contentTF.text=[NSString stringWithFormat:@"result:%d",result];
    [self.callBackItem setNeedsDisplay];

}
//设置配置信息回调
-(void)oneKeySetDeviceConfigInfoCallBack:(WHBleResultType)result{
    
    DebugLog(@"oneKeySetDeviceConfigInfoCallBack:%d",result);
    
    self.callBackItem.contentTF.text=[NSString stringWithFormat:@"result:%d",result];
    [self.callBackItem setNeedsDisplay];

}
//更改设备密码回调
-(void)oneKeyChangeDevPswCallBack:(WHBleResultType)result{

    DebugLog(@"oneKeySetDeviceConfigInfoCallBack:%d",result);
    
    self.callBackItem.contentTF.text=[NSString stringWithFormat:@"result:%d",result];
    [self.callBackItem setNeedsDisplay];
}
//更改设备名称回调
-(void)oneKeyChangeDevNameCallBack:(WHBleResultType)result{
    DebugLog(@"oneKeySetDeviceConfigInfoCallBack:%d",result);
    
    self.callBackItem.contentTF.text=[NSString stringWithFormat:@"result:%d",result];
    [self.callBackItem setNeedsDisplay];

}
//一键开门带关闭时间回调
-(void)oneKeyOpenDeviceWithTimeCallBack:(WHBleResultType)result{
    DebugLog(@"oneKeySetDeviceConfigInfoCallBack:%d",result);
    
    self.callBackItem.contentTF.text=[NSString stringWithFormat:@"result:%d",result];
    [self.callBackItem setNeedsDisplay];

}
//读取硬件或软件版本信息回调
-(void)oneKeyReadVerInfoCallBack:(WHBleResultType)result verInfo:(NSString *)verInfo{
    DebugLog(@"oneKeySetDeviceConfigInfoCallBack:%d",result);
    
    self.callBackItem.contentTF.text=[NSString stringWithFormat:@"result:%d",result];
    [self.callBackItem setNeedsDisplay];

}
//读取时钟信息回调
-(void)oneKeyReadClockCallBack:(WHBleResultType)result clockInfo:(NSString *)clockInfo{
    DebugLog(@"oneKeySetDeviceConfigInfoCallBack:%d",result);
    
    self.callBackItem.contentTF.text=[NSString stringWithFormat:@"result:%d",result];
    [self.callBackItem setNeedsDisplay];
}
//设置时钟回调
-(void)oneKeySetClockCallBack:(WHBleResultType)result{
    DebugLog(@"oneKeySetDeviceConfigInfoCallBack:%d",result);
    
    self.callBackItem.contentTF.text=[NSString stringWithFormat:@"result:%d",result];
    [self.callBackItem setNeedsDisplay];

}

//增加密码/卡片回调
-(void)oneKeyAddPaswdAndCardKeyCallBack:(WHBleResultType)result{
    
}
//删除密码/卡片回调
-(void)oneKeyDeletePaswdAndCardKeyCallBack:(WHBleResultType)result{

}
//批量钥匙添加到falsh中回调
-(void)oneKeyFlashAddKeyCallBack:(WHBleResultType)result{

}
//批量删除钥匙回调
-(void)oneKeyFlashDeleteKeyCallBack:(WHBleResultType)result{

}
//配置门禁连接服务器IP回调
-(void)oneKeyConfigServerCallBack:(WHBleResultType)result{

}
//配置服务器门禁心跳
-(void)oneKeyServiceConfigDeviceCallBack:(WHBleResultType)result{

}

-(void)errorCallBack:(ErrorType)type
{
    DebugLog(@"errorCallBack:%d",type);
    
    self.callBackItem.contentTF.text=[NSString stringWithFormat:@"errorCallBack:%d",type];

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

@end
