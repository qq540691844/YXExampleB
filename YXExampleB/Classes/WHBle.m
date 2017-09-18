//
//  WHBle.m
//  WHBle
//
//  Created by admin on 2017/9/11.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "WHBle.h"
#import "BabyBluetooth.h"

//常用变量
#define DebugLog(s, ...) NSLog(@"%s(%d): %@", __FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])

#define MJWeakSelf __weak typeof(self) weakSelf = self;

typedef NS_ENUM(NSUInteger, RequestType) {/**<请求类型 */
    RequestTypeOneKeyOpenDevice,//默认从0开始 /**<一键开门 */
    RequestTypeOneKeyReadDeviceConfigInfo,/**<读取配置 */
    RequestTypeOneKeySetDeviceConfigInfo,/**<设置配置 */
    RequestTypeOneKeyChangeDevPsw,/**<更改密码 */
    RequestTypeOneKeyChangeDevName,/**<更改设备名称 */
    RequestTypeOneKeyOpenDeviceWithTime,/**<一键开门带关闭时间 */
    RequestTypeOneKeyReadVerInfo,/**<读取软件或硬件版本信息 */
    RequestTypeOneKeyReadClock,/**<读取时钟信息 */
    RequestTypeOneKeySetClock,/**<设置时钟信息，分年月日和时分秒 */
    RequestTypeOneKeyAddPaswdAndCardKey,/**<添加卡片/密码到设备中(少量) */
    RequestTypeOneKeyDeletePaswdAndCardKey,/**<从设备中删除卡片/密码(少量) */
    RequestTypeOneKeyFlashAddKey,/**<增加密码/卡片到锁体中（适用于批量钥匙添加Flash中） */
    RequestTypeOneKeyFlashDeleteKey,/**<删除锁体中密码/卡片（适用于删除批量钥匙）*/
    RequestTypeOneKeyConfigServer,/**<配置门禁连接的服务器IP信息*/
    RequestTypeOneKeyServiceConfigDevice/**<配置服务器门禁心跳*/
};


@interface WHBle()

@property (nonatomic,strong) BabyBluetooth *baby;

@property (nonatomic,assign) RequestType type;

@property (nonatomic,strong) CBCharacteristic *characteristic;

@property (nonatomic,strong)NSTimer *timer;

@property (nonatomic,copy) NSString *pwd;

@property (nonatomic,copy) NSString *configStr;

@property (nonatomic,copy) NSString *nPwd;

@property (nonatomic,copy) NSString *nName;

@property (nonatomic,copy) NSString *cTime;

@property (nonatomic,copy) NSString *vType;

@property (nonatomic,copy) NSString *clockStr;

@property (nonatomic,copy) NSString *cType;

@property (nonatomic,copy) NSString *cardID;

@property (nonatomic,copy) NSString *cardCount;

@property (nonatomic,copy) NSString *serverIP;

@property (nonatomic,copy) NSString *heartBeat;
@end

@implementation WHBle

//单例模式
+ (instancetype)shareWHBle {
    static WHBle *ble = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        ble = [[WHBle alloc]init];
    });
    return ble;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        //初始化对象
    }
    return self;
    
}


//蓝牙初始化
-(void)bleInit{
    
    DebugLog(@"初始化成功");
    //初始化BabyBluetooth 蓝牙库
    _baby = [BabyBluetooth shareBabyBluetooth];
    //设置蓝牙委托
    [self babyDelegate];
    //设置委托后直接可以使用，无需等待CBCentralManagerStatePoweredOn状态
    
    
    
}

-(void)babyDelegate{
    
    MJWeakSelf
    //设置扫描到设备的委托
    [_baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        DebugLog(@"搜索到了设备:%@",peripheral.name);
        
        if (weakSelf.searchDelegate && [weakSelf.searchDelegate respondsToSelector:@selector(bleDidDiscoverPeripherals:advertisementData:RSSI:)]) {
            
            [weakSelf.searchDelegate bleDidDiscoverPeripherals:peripheral advertisementData:advertisementData RSSI:RSSI];
        }
    }];
    
    //连接设备成功
    [_baby setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
        DebugLog(@"成功连接了设备:%@",peripheral.name);
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(bleDidConnectPeripheral:status:)]) {
            
            [weakSelf.delegate bleDidConnectPeripheral:peripheral status:CONNECT_SUCCESSED];
        }
        
    }];
    
    //连接设备失败
    [_baby setBlockOnFailToConnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        DebugLog(@"连接设备失败，设备名称:%@，错误原因:%@",peripheral.name,error.description);
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(bleDidConnectPeripheral:status:)]) {
            
            [weakSelf.delegate bleDidConnectPeripheral:peripheral status:CONNECT_FAILED];
        }
        
    }];
    
    //发现服务
    [_baby setBlockOnDiscoverServices:^(CBPeripheral *peripheral, NSError *error) {
        DebugLog(@"设备服务数量:%zd,外设服务:%@",peripheral.services.count,peripheral.services);
        
    }];
    //发现特征
    [_baby setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        DebugLog(@"===service name:%@,服务的特征: %@",service.UUID,service.characteristics);
        
        [weakSelf.timer invalidate];
        
        for (CBCharacteristic *characteristic in service.characteristics) {
            
            if ([[NSString stringWithFormat:@"%@",characteristic.UUID] isEqualToString:@"FF01"]) {
                
                DebugLog(@" characteristic:%@ and value:%@ characteristic.properties:%lu",[NSString stringWithFormat:@"%@",characteristic.UUID],[NSString stringWithFormat:@"%@",characteristic.value],(characteristic.properties & CBCharacteristicPropertyRead));
                
                weakSelf.characteristic=characteristic;
                
                [weakSelf setNotify:peripheral type:weakSelf.type];
                
                
            }
        }
    
        
        
        
    }];
    
    //设置写数据成功的block
    [_baby setBlockOnDidWriteValueForCharacteristic:^(CBCharacteristic *characteristic, NSError *error) {
        
        if (!error) {
            DebugLog(@" characteristic:%@ and new value:%@",[NSString stringWithFormat:@"%@",characteristic.UUID], [NSString stringWithFormat:@"%@",characteristic.value]);
            
            NSString *valueStr = [weakSelf hexStringForData:characteristic.value];
            
            if (valueStr.length<20) {
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(errorCallBack:)]) {
                    
                    [weakSelf.delegate errorCallBack:ERROR_RETURN_WRONG_LENGTH_CHARACTERISTIC_VALUE];
                }
                return;
                
            }
            
            NSString *lengthStr=[valueStr substringWithRange:NSMakeRange(4, 2)];
            
            //16进制字符串转10进制int
            int length = [weakSelf hexToIntWithStr:lengthStr];
            
            NSString *resultStr=[valueStr substringWithRange:NSMakeRange(4+(length-1)*2, 2)];
            
            WHBleResultType type=(WHBleResultType)[resultStr integerValue];
            
            DebugLog(@"---valueStr:%@---lengthStr:%@---length:%d---resultStr:%@",valueStr,lengthStr,length,resultStr);
            
            switch (weakSelf.type) {
                case RequestTypeOneKeyOpenDevice:
                {
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(oneKeyOpenDeviceCallBack:)]) {
                        
                        [weakSelf.delegate oneKeyOpenDeviceCallBack:type];
                    }
                }
                    break;
                case RequestTypeOneKeyReadDeviceConfigInfo:
                {
                    int disConnectTime=[weakSelf hexToIntWithStr:[valueStr substringWithRange:NSMakeRange(18, 2)]];
                    
                    WHBleTxPowerType txPower=(WHBleTxPowerType)[weakSelf hexToIntWithStr:[valueStr substringWithRange:NSMakeRange(20, 2)]];
                    
                    int activeTime=[weakSelf hexToIntWithStr:[valueStr substringWithRange:NSMakeRange(22, 2)]];
                    
                    int configBit=[weakSelf hexToIntWithStr:[valueStr substringWithRange:NSMakeRange(24, 2)]];
                    
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(oneKeyReadDeviceConfigInfoCallBack:disConnectTime:txPower:activeTime:configBit:)]) {
                        
                        [weakSelf.delegate oneKeyReadDeviceConfigInfoCallBack:type disConnectTime:disConnectTime txPower:txPower activeTime:activeTime configBit:configBit];
                    }
                    
                }
                    break;
                case RequestTypeOneKeySetDeviceConfigInfo:
                {
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(oneKeySetDeviceConfigInfoCallBack:)]) {
                        
                        [weakSelf.delegate oneKeySetDeviceConfigInfoCallBack:type];
                    }
                }
                    break;
                case RequestTypeOneKeyChangeDevPsw:
                {
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(oneKeyChangeDevPswCallBack:)]) {
                        
                        [weakSelf.delegate oneKeyChangeDevPswCallBack:type];
                    }
                    
                }
                    break;
                case RequestTypeOneKeyChangeDevName:
                {
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(oneKeyChangeDevNameCallBack:)]) {
                        
                        [weakSelf.delegate oneKeyChangeDevNameCallBack:type];
                    }
                    
                }
                    break;
                case RequestTypeOneKeyOpenDeviceWithTime:
                {
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(oneKeyOpenDeviceWithTimeCallBack:)]) {
                        
                        [weakSelf.delegate oneKeyOpenDeviceWithTimeCallBack:type];
                    }
                    
                }
                    break;
                case RequestTypeOneKeyReadVerInfo:
                {
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(oneKeyReadVerInfoCallBack:verInfo:)]) {
                        
                        [weakSelf.delegate oneKeyReadVerInfoCallBack:type verInfo:@"verInfo"];
                    }
                    
                }
                    break;
                case RequestTypeOneKeyReadClock:
                {
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(oneKeyReadClockCallBack:clockInfo:)]) {
                        
                        [weakSelf.delegate oneKeyReadClockCallBack:type clockInfo:@"2017-10-1"];
                    }
                    
                }
                    break;
                case RequestTypeOneKeySetClock:
                {
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(oneKeySetClockCallBack:)]) {
                        
                        [weakSelf.delegate oneKeySetClockCallBack:type];
                    }
                    
                }
                    break;
                case RequestTypeOneKeyAddPaswdAndCardKey:
                {
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(oneKeyAddPaswdAndCardKeyCallBack:)]) {
                        
                        [weakSelf.delegate oneKeyAddPaswdAndCardKeyCallBack:type];
                    }
                    
                }
                    break;
                case RequestTypeOneKeyDeletePaswdAndCardKey:
                {
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(oneKeyDeletePaswdAndCardKeyCallBack:)]) {
                        
                        [weakSelf.delegate oneKeyDeletePaswdAndCardKeyCallBack:type];
                    }
                    
                }
                    break;
                case RequestTypeOneKeyFlashAddKey:
                {
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(oneKeyFlashAddKeyCallBack:)]) {
                        
                        [weakSelf.delegate oneKeyFlashAddKeyCallBack:type];
                    }
                    
                }
                    break;
                case RequestTypeOneKeyFlashDeleteKey:
                {
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(oneKeyFlashDeleteKeyCallBack:)]) {
                        
                        [weakSelf.delegate oneKeyFlashDeleteKeyCallBack:type];
                    }
                    
                }
                    break;
                case RequestTypeOneKeyConfigServer:
                {
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(oneKeyConfigServerCallBack:)]) {
                        
                        [weakSelf.delegate oneKeyConfigServerCallBack:type];
                    }

                    
                }
                    break;
                case RequestTypeOneKeyServiceConfigDevice:
                {
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(oneKeyServiceConfigDeviceCallBack:)]) {
                        
                        [weakSelf.delegate oneKeyServiceConfigDeviceCallBack:type];
                    }
                    
                }
                    break;
                    
                default:
                    break;
            }

            
            
            
            
        }else{
            DebugLog(@"error:%@",error);
            
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(errorCallBack:)]) {
                
                [weakSelf.delegate errorCallBack:INPUT_ERROR_PWD];
            }
            
        }
        
        
        
        
    }];
    
    //设置读取characteristics的委托
    [_baby setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        DebugLog(@"error:%@",error);
        DebugLog(@" characteristic:%@ and value:%@",[NSString stringWithFormat:@"%@",characteristic.UUID], [NSString stringWithFormat:@"%@",characteristic.value]);
        
    }];
    
    //订阅状态改变
    [_baby setBlockOnDidUpdateNotificationStateForCharacteristic:^(CBCharacteristic *characteristic, NSError *error) {
        DebugLog(@"error:%@",error);
        DebugLog(@" characteristic:%@ and value:%@",[NSString stringWithFormat:@"%@",characteristic.UUID], [NSString stringWithFormat:@"%@",characteristic.value]);
        
    }];
    
    //过滤器
    //设置查找设备的过滤器
    [_baby setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        //最常用的场景是查找某一个前缀开头的设备 most common usage is discover for peripheral that name has common prefix
        //if ([peripheralName hasPrefix:@"Pxxxx"] ) {
        //    return YES;
        //}
        //return NO;
        //设置查找规则是名称大于1 ， the search rule is peripheral.name length > 1
        if (peripheralName.length >1) {
            return YES;
        }
        return NO;
    }];
    
}


//蓝牙搜索
-(void)scanDevice:(int)timeout{
    
    _baby.scanForPeripherals().begin().stop(timeout);
    
}

//停止搜索
-(void)stopSearch
{
    [_baby cancelScan];
}

//连接设备
-(void)connectDeviece:(CBPeripheral *)peripheral
{
    _baby.having(peripheral).connectToPeripherals().begin();
    
}

//断开连接
- (void)disConnectDeviece:(CBPeripheral *)peripheral
{
    if (peripheral.state==CBPeripheralStateConnected) {
        
        if (self.characteristic.isNotifying) {
            [_baby cancelNotify:peripheral characteristic:self.characteristic];
        }
        
        [_baby cancelPeripheralConnection:peripheral];
       
    }
}
//断开所有连接
- (void)disConnectAllDevieces
{
    [_baby cancelAllPeripheralsConnection];
}

//一键开锁
-(void)oneKeyOpenDevice:(CBPeripheral *)peripheral password:(NSString *)pwd
{
    
    if (pwd.length!=8) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(errorCallBack:)]) {
            
            [self.delegate errorCallBack:INPUT_ERROR_PWD];
        }
        return;
    }
    
    self.type=RequestTypeOneKeyOpenDevice;
    self.pwd=pwd;
    
    [self commonFunctionWithDeveice:peripheral];
    
    
    
}

//读取设备配置信息
-(void)oneKeyReadDeviceConfigInfo:(CBPeripheral *)peripheral password:(NSString *)pwd{
    
    if (pwd.length!=8) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(errorCallBack:)]) {
            
            [self.delegate errorCallBack:INPUT_ERROR_PWD];
        }
        return;
    }
    
    self.type=RequestTypeOneKeyReadDeviceConfigInfo;
    self.pwd=pwd;
    
    [self commonFunctionWithDeveice:peripheral];

}
//设置设备配置信息
-(void)oneKeySetDeviceConfigInfo:(CBPeripheral *)peripheral password:(NSString *)pwd disConnectTime:(int)disConnect txPower:(WHBleTxPowerType)txPower activeTime:(int)activeTime configBit:(int)configBit{
    
    if (pwd.length!=8) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(errorCallBack:)]) {
            
            [self.delegate errorCallBack:INPUT_ERROR_PWD];
        }
        return;
    }
    
    if (disConnect<20 || disConnect>255) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(errorCallBack:)]) {
            
            [self.delegate errorCallBack:INPUT_ERROR_DISCONNECTTIME];
        }
        return;
    }
    
    if (txPower!=TX_POWER_MINUS_23_DBM && txPower!=TX_POWER_MINUS_6_DBM && txPower!=TX_POWER_0_DBM && txPower!=TX_POWER_4_DBM) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(errorCallBack:)]) {
            
            [self.delegate errorCallBack:INPUT_ERROR_TXPOWER];
        }
        return;
    }
    
    if (activeTime<10 || activeTime>100) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(errorCallBack:)]) {
            
            [self.delegate errorCallBack:INPUT_ERROR_ACTIVETIME];
        }
        return;
    }
    
    if (configBit <0 || configBit>3) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(errorCallBack:)]) {
            
            [self.delegate errorCallBack:INPUT_ERROR_CONFIGBIT];
        }
        return;
    }
    
    self.type=RequestTypeOneKeySetDeviceConfigInfo;
    self.pwd=pwd;
    
    self.configStr=[NSString stringWithFormat:@"%@%@%@%@",[self ToHex:disConnect],[self ToHex:txPower],[self ToHex:activeTime],[self ToHex:configBit]];
    
    DebugLog(@"---configStr:%@",_configStr);
    
    [self commonFunctionWithDeveice:peripheral];

}
//更改设备密码
-(void)oneKeyChangeDevPsw:(CBPeripheral *)peripheral password:(NSString *)pwd newPassword:(NSString *)nPwd{
    
    if (pwd.length!=8) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(errorCallBack:)]) {
            
            [self.delegate errorCallBack:INPUT_ERROR_PWD];
        }
        return;
    }
    
    if (nPwd.length!=8) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(errorCallBack:)]) {
            
            [self.delegate errorCallBack:INPUT_ERROR_NEWPWD];
        }
        return;
    }
    
    self.type=RequestTypeOneKeyChangeDevPsw;
    self.pwd=pwd;
    self.nPwd=nPwd;
    
    [self commonFunctionWithDeveice:peripheral];

}
//更改设备名称
-(void)oneKeyChangeDevName:(CBPeripheral *)peripheral password:(NSString *)pwd newDevieceName:(NSString *)nName{
    
    if (pwd.length!=8) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(errorCallBack:)]) {
            
            [self.delegate errorCallBack:INPUT_ERROR_PWD];
        }
        return;
    }
    
    if (nName.length!=4) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(errorCallBack:)]) {
            
            [self.delegate errorCallBack:INPUT_ERROR_NEWNAME];
        }
        return;
    }
    
    self.type=RequestTypeOneKeyChangeDevName;
    self.pwd=pwd;
    
    NSString *nNameStr=[self toAsciiHesStrWithStr:nName];
    
    self.nName=nNameStr;
    
    [self commonFunctionWithDeveice:peripheral];

}
//开锁指令（带关闭时间）
-(void)oneKeyOpenDevice:(CBPeripheral *)peripheral password:(NSString *)pwd withTime:(int)cTime{
    
    if (pwd.length!=8) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(errorCallBack:)]) {
            
            [self.delegate errorCallBack:INPUT_ERROR_PWD];
        }
        return;
    }
    
    if (cTime < 0 || cTime > 10) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(errorCallBack:)]) {
            
            [self.delegate errorCallBack:INPUT_ERROR_CLOSETIME];
        }
        return;
    }
    
    self.type=RequestTypeOneKeyOpenDeviceWithTime;
    self.pwd=pwd;
    self.cTime=[self ToHex:cTime];
    
    [self commonFunctionWithDeveice:peripheral];

}
//读取设备和软件的版本信息
-(void)oneKeyReadVerInfo:(CBPeripheral *)peripheral password:(NSString *)pwd versionType:(WHVersionType)vType{
    
    if (pwd.length!=8) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(errorCallBack:)]) {
            
            [self.delegate errorCallBack:INPUT_ERROR_PWD];
        }
        return;
    }
    
    if (vType != WHVersionTypeHardWare && vType != WHVersionTypeSoftWare) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(errorCallBack:)]) {
            
            [self.delegate errorCallBack:INPUT_ERROR_VERSIONTYPE];
        }
        return;
    }
    
    
    self.type=RequestTypeOneKeyReadVerInfo;
    self.pwd=pwd;
    if (vType == WHVersionTypeHardWare) {
        
        self.vType=@"01";
    }else{
        self.vType=@"10";
    }
    
    [self commonFunctionWithDeveice:peripheral];

}
//读取锁体中的时钟信息
-(void)oneKeyReadClock:(CBPeripheral *)peripheral password:(NSString *)pwd{
    
    if (pwd.length!=8) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(errorCallBack:)]) {
            
            [self.delegate errorCallBack:INPUT_ERROR_PWD];
        }
        return;
    }
    self.type=RequestTypeOneKeyReadClock;
    self.pwd=pwd;
    
    [self commonFunctionWithDeveice:peripheral];

}
//设置更改锁体中时钟信息
-(void)oneKeySetClock:(CBPeripheral *)peripheral password:(NSString *)pwd clockStr:(NSString *)time type:(WHClockType)cType{
    
    if (pwd.length!=8) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(errorCallBack:)]) {
            
            [self.delegate errorCallBack:INPUT_ERROR_PWD];
        }
        return;
    }
    
    self.type=RequestTypeOneKeySetClock;
    self.pwd=pwd;
    if (cType == WHClockTypeDate) {
        
        self.cType=@"01";
    }else{
        self.cType=@"10";
    }
    
    [self commonFunctionWithDeveice:peripheral];

}

//增加密码/卡片到锁体中（适用于临时或者少量钥匙添加）
-(void)oneKeyAddPaswdAndCardKey:(CBPeripheral *)peripheral password:(NSString *)pwd cardID:(NSString *)cardID{
    
    if (pwd.length!=8) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(errorCallBack:)]) {
            
            [self.delegate errorCallBack:INPUT_ERROR_PWD];
        }
        return;
    }
    
    if (cardID.length!=10) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(errorCallBack:)]) {
            
            [self.delegate errorCallBack:INPUT_ERROR_CARDID];
        }
        return;
    }
    
    self.type=RequestTypeOneKeyAddPaswdAndCardKey;
    self.pwd=pwd;
    self.cardID=cardID;
    
    [self commonFunctionWithDeveice:peripheral];

}
//删除锁体中密码/卡片（适用于删除临时或者少量钥匙）
-(void)oneKeyDeletePaswdAndCardKey:(CBPeripheral *)peripheral password:(NSString *)pwd cardID:(NSString *)cardID{
    
    if (pwd.length!=8) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(errorCallBack:)]) {
            
            [self.delegate errorCallBack:INPUT_ERROR_PWD];
        }
        return;
    }
    
    if (cardID.length!=10) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(errorCallBack:)]) {
            
            [self.delegate errorCallBack:INPUT_ERROR_CARDID];
        }
        return;
    }
    
    self.type=RequestTypeOneKeyDeletePaswdAndCardKey;
    self.pwd=pwd;
    self.cardID=cardID;
    
    [self commonFunctionWithDeveice:peripheral];

}
//增加密码/卡片到锁体中（适用于批量钥匙添加Flash中）
-(void)oneKeyFlashAddKey:(CBPeripheral *)peripheral password:(NSString *)pwd cardID:(NSString *)cardID count:(NSString *)count{
    
    if (pwd.length!=8) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(errorCallBack:)]) {
            
            [self.delegate errorCallBack:INPUT_ERROR_PWD];
        }
        return;
    }
    
    if (cardID.length!=10) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(errorCallBack:)]) {
            
            [self.delegate errorCallBack:INPUT_ERROR_CARDID];
        }
        return;
    }
    
    if ([count intValue] >99) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(errorCallBack:)]) {
            
            [self.delegate errorCallBack:INPUT_ERROR_CARD_COUNT];
        }
        return;
    }
    
    
    
    self.type=RequestTypeOneKeyFlashAddKey;
    self.pwd=pwd;
    self.cardID=cardID;
    self.cardCount=count;
    
    [self commonFunctionWithDeveice:peripheral];

}
//删除锁体中密码/卡片（适用于删除批量钥匙）
-(void)oneKeyFlashDeleteKey:(CBPeripheral *)peripheral password:(NSString *)pwd cardID:(NSString *)cardID count:(NSString *)count{
    if (pwd.length!=8) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(errorCallBack:)]) {
            
            [self.delegate errorCallBack:INPUT_ERROR_PWD];
        }
        return;
    }
    
    if (cardID.length!=10) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(errorCallBack:)]) {
            
            [self.delegate errorCallBack:INPUT_ERROR_CARDID];
        }
        return;
    }
    
    if ([count intValue] >99) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(errorCallBack:)]) {
            
            [self.delegate errorCallBack:INPUT_ERROR_CARD_COUNT];
        }
        return;
    }
    
    
    
    self.type=RequestTypeOneKeyFlashDeleteKey;
    self.pwd=pwd;
    self.cardID=cardID;
    self.cardCount=count;
    
    [self commonFunctionWithDeveice:peripheral];

}
//配置门禁连接的服务器IP信息 serverIP服务器IP
-(void)oneKeyConfigServer:(CBPeripheral *)peripheral password:(NSString *)pwd serverIP:(NSString *)serverIP{
    if (pwd.length!=8) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(errorCallBack:)]) {
            
            [self.delegate errorCallBack:INPUT_ERROR_PWD];
        }
        return;
    }
    
    if (serverIP.length!=8) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(errorCallBack:)]) {
            
            [self.delegate errorCallBack:INPUT_ERROR_SERVERIP];
        }
        return;
    }
    
    
    
    self.type=RequestTypeOneKeyConfigServer;
    self.pwd=pwd;
    self.serverIP=serverIP;
    
    [self commonFunctionWithDeveice:peripheral];

}
//配置服务器门禁心跳  heartBeat心跳包
-(void)oneKeyServiceConfigDevice:(CBPeripheral *)peripheral password:(NSString *)pwd heartBeat:(NSString *)heartBeat{
    if (pwd.length!=8) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(errorCallBack:)]) {
            
            [self.delegate errorCallBack:INPUT_ERROR_PWD];
        }
        return;
    }
    
    if (heartBeat.length!=8) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(errorCallBack:)]) {
            
            [self.delegate errorCallBack:INPUT_ERROR_HEART_BEAT];
        }
        return;
    }
    
    
    
    self.type=RequestTypeOneKeyServiceConfigDevice;
    self.pwd=pwd;
    self.heartBeat=heartBeat;
    
    [self commonFunctionWithDeveice:peripheral];

}

// 订阅并writeValue发送请求Data
-(void)setNotify:(CBPeripheral *)peripheral type:(RequestType)type
{
    if (self.characteristic.properties & CBCharacteristicPropertyNotify ||  self.characteristic.properties & CBCharacteristicPropertyIndicate) {
        DebugLog(@"订阅状态:%zd",self.characteristic.isNotifying);
        if(self.characteristic.isNotifying) {
            //[_baby cancelNotify:peripheral characteristic:self.characteristic];
        }else{
            [_baby notify:peripheral
           characteristic:self.characteristic
                    block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                        DebugLog(@"notify block");
                    }];
            
        }
    }
    else{
        DebugLog(@"这个characteristic没有nofity的权限");
        return;
    }
    
    NSData *data;
    NSString *devieceId=[peripheral.name substringWithRange:NSMakeRange(2, 8)];
    DebugLog(@"---devieceId:%@",devieceId);
    switch (type) {
        case RequestTypeOneKeyOpenDevice:
        {
            //            Byte b[16] = {0xFF,0x99,0xAA,0x55,0x0B,0x01,0x00,0xC4,0x80,0x06,0xE2,0x12,0x34,0x56,0x78,0x10};
            //            data= [NSData dataWithBytes:&b length:sizeof(b)];
            
            NSString *str=[NSString stringWithFormat:@"AA550B0100%@%@10",devieceId,self.pwd];
            
            data=[self hexToBytesWithStr:str];
            
        }
            break;
        case RequestTypeOneKeyReadDeviceConfigInfo:
        {
            
            NSString *str=[NSString stringWithFormat:@"AA550B0200%@%@10",devieceId,self.pwd];
            
            data=[self hexToBytesWithStr:str];
        }
            break;
        case RequestTypeOneKeySetDeviceConfigInfo:
        {
            
            NSString *str=[NSString stringWithFormat:@"AA55120300%@%@%@10",devieceId,self.pwd,self.configStr];
            
            data=[self hexToBytesWithStr:str];
        }
            break;
        case RequestTypeOneKeyChangeDevPsw:
        {
            
            NSString *str=[NSString stringWithFormat:@"AA550F0400%@%@%@10",devieceId,self.pwd,self.nPwd];
            
            data=[self hexToBytesWithStr:str];
        }
            break;
        case RequestTypeOneKeyChangeDevName:
        {
            
            NSString *str=[NSString stringWithFormat:@"AA550F0500%@%@%@10",devieceId,self.pwd,self.nName];
            
            data=[self hexToBytesWithStr:str];
        }
            break;
        case RequestTypeOneKeyOpenDeviceWithTime:
        {
            
            NSString *str=[NSString stringWithFormat:@"AA550C0600%@%@%@10",devieceId,self.pwd,self.cTime];
            
            data=[self hexToBytesWithStr:str];
        }
            break;
        case RequestTypeOneKeyReadVerInfo:
        {
            
            NSString *str=[NSString stringWithFormat:@"AA550C0700%@%@%@10",devieceId,self.pwd,self.vType];
            
            data=[self hexToBytesWithStr:str];
        }
            break;
        case RequestTypeOneKeyReadClock:
        {
            
            NSString *str=[NSString stringWithFormat:@"AA550B0800%@%@10",devieceId,self.pwd];
            
            data=[self hexToBytesWithStr:str];
        }
            break;
        case RequestTypeOneKeySetClock:
        {
            
            NSString *str=[NSString stringWithFormat:@"AA550F0900%@%@%@%@10",devieceId,self.pwd,self.clockStr,self.cType];
            
            data=[self hexToBytesWithStr:str];
        }
            break;
        case RequestTypeOneKeyAddPaswdAndCardKey:
        {
            
            NSString *str=[NSString stringWithFormat:@"AA55100A00%@%@%@10",devieceId,self.pwd,self.cardID];
            
            data=[self hexToBytesWithStr:str];
        }
            break;
        case RequestTypeOneKeyDeletePaswdAndCardKey:
        {
            
            NSString *str=[NSString stringWithFormat:@"AA55100B00%@%@%@10",devieceId,self.pwd,self.cardID];
            
            data=[self hexToBytesWithStr:str];
        }
            break;
        case RequestTypeOneKeyFlashAddKey:
        {
            
            NSString *str=[NSString stringWithFormat:@"AA55110C00%@%@%@%@10",devieceId,self.pwd,self.cardID,self.cardCount];
            
            data=[self hexToBytesWithStr:str];
        }
            break;
        case RequestTypeOneKeyFlashDeleteKey:
        {
            
            NSString *str=[NSString stringWithFormat:@"AA55110D00%@%@%@%@10",devieceId,self.pwd,self.cardID,self.cardCount];
            
            data=[self hexToBytesWithStr:str];
        }
            break;
        case RequestTypeOneKeyConfigServer:
        {
            
            NSString *str=[NSString stringWithFormat:@"AA550F0E00%@%@%@10",devieceId,self.pwd,self.serverIP];
            
            data=[self hexToBytesWithStr:str];
        }
            break;
        case RequestTypeOneKeyServiceConfigDevice:
        {
            
            NSString *str=[NSString stringWithFormat:@"AA550F0F00%@%@%@10",devieceId,self.pwd,self.heartBeat];
            
            data=[self hexToBytesWithStr:str];
        }
            break;
            
        default:
            break;
    }
    
    DebugLog(@"写值:%@",data);
    [peripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
    
    
}

#pragma mark private method
//共有连接蓝牙获取服务特征并读取特征value的方法，设置15s超时
-(void)commonFunctionWithDeveice:(CBPeripheral *)peripheral{
    
    _baby.having(peripheral).connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin().stop(30);
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(timeoutAction) userInfo:nil repeats:NO];
}

-(void)timeoutAction
{
    DebugLog(@"----timeoutAction");
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(errorCallBack:)]) {
        
        [self.delegate errorCallBack:ERROR_ACTION_OUTTIME];
        
        
    }

}

//字符串转Data
-(NSData*) hexToBytesWithStr:(NSString *)str {
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= str.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [str substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}
//Data转字符串
- (NSString*)hexStringForData:(NSData*)data

{
    
    if (data == nil) {
        
        return nil;
        
    }
    
    NSMutableString* hexString = [NSMutableString string];
    
    const unsigned char *p = [data bytes];
    
    
    
    for (int i=0; i < [data length]; i++) {
        
        [hexString appendFormat:@"%02x", *p++];
        
    }
    
    return hexString;
    
}

//10进制数转16进制字符串
-(NSString *)ToHex:(long long int)tmpid
{
    NSString *nLetterValue;
    NSString *str =@"";
    long long int ttmpig;
    for (int i = 0; i<9; i++) {
        ttmpig=tmpid%16;
        tmpid=tmpid/16;
        switch (ttmpig)
        {
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
            default:nLetterValue=[[NSString alloc]initWithFormat:@"%lld",ttmpig];
                
        }
        str = [nLetterValue stringByAppendingString:str];
        if (tmpid == 0) {
            break;
        }
        
    }
    
    if (str.length==1) {
        
        str=[NSString stringWithFormat:@"0%@",str];
    }
    
    return str;
}

//16进制字符串转10进制int
-(int)hexToIntWithStr:(NSString *)str{
    
    NSString * lengthStr10 = [NSString stringWithFormat:@"%lu",strtoul([str UTF8String],0,16)];
    
    int length = [lengthStr10 intValue];
    
    return length;

}

//字符串转16进制ascii码字符串
-(NSString *)toAsciiHesStrWithStr:(NSString *)str{

    NSString *nStr=@"";
    for (int i=0; i < str.length; i++) {
        
        int asciiCode = [str characterAtIndex:i];
        
        DebugLog(@"------%d",asciiCode);
        
        NSString *temp=[self ToHex:asciiCode];
        DebugLog(@"------%@",temp);
        
        nStr=[nStr stringByAppendingString:temp];
        
    }
    
    DebugLog(@"------%@",nStr);
    
    return nStr;

}




@end
