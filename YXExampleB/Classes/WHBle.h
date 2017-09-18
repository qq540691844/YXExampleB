//
//  WHBle.h
//  WHBle
//
//  Created by admin on 2017/9/11.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

//连接状态
typedef NS_ENUM(NSUInteger, ConnectStatus) {
    CONNECT_FAILED = 0,//默认从0开始
    CONNECT_SUCCESSED
};


/*!
 *   TX_POWER  0~3 蓝牙发送功率，默认为2
 *   TX_POWER_MINUS_23_DBM(0)
 *   TX_POWER_MINUS_6_DBM(1)
 *   TX_POWER_0_DBM(2)
 *   TX_POWER_4_DBM(3)
*/
typedef NS_ENUM(NSUInteger, WHBleTxPowerType) {
    TX_POWER_MINUS_23_DBM = 0,
    TX_POWER_MINUS_6_DBM,
    TX_POWER_0_DBM,
    TX_POWER_4_DBM
};

/*!
 *   WHVersionType  版本信息
 *   WHVersionTypeHardWare 硬件版本
 *   WHVersionTypeSoftWare 软件版本
 */
typedef NS_ENUM(NSUInteger, WHVersionType) {
    WHVersionTypeHardWare = 0,
    WHVersionTypeSoftWare
};

/*!
 *   WHClockType  版本信息
 *   WHVersionTypeHardWare 硬件版本
 *   WHVersionTypeSoftWare 软件版本
 */
typedef NS_ENUM(NSUInteger, WHClockType) {
    WHClockTypeDate = 0,
    WHClockTypeTime
};

/* 设备结果返回状态 */
typedef NS_ENUM(NSInteger, WHBleResultType) {
    WHBLE_RESULT_SUCCESS = 0,/**<操作成功 */
    WHBLE_RESULT_FAILED,/**<操作失败 */
    WHBLE_RESULT_SYSTEM_ERROR, /**<系统码错误 */
    WHBLE_RESULT_DEVEICEID_ERROR, /**<设备ID错误 */
    WHBLE_RESULT_PASSWORD_ERROR,/**<用户密码错误 */
    WHBLE_RESULT_TIME_INVALIDATE,/**<时间无效 */
    WHBLE_RESULT_NOT_LOGIN,/**<没有登录 */
    WHBLE_RESULT_KEY_NOT_EXIST,/**<钥匙不存在 */
    WHBLE_RESULT_FLASH_FULL,/**<flash已满 */
    WHBLE_RESULT_KEY_EXIST,/**<钥匙已经不存 */
    WHBLE_RESULT_COMMAND_NOT_SUPPORT,/**<命令不支持*/
    WHBLE_RESULT_DEVEICE_NOT_REGISTER,/**<设备未注册 */
    WHBLE_RESULT_PASSWORD_DEFAULT,/**<设备密码为默认密码 */
    WHBLE_RESULT_SERVEICE_NOT_USE = 21,/**<服务未启用 */
    WHBLE_RESULT_DEVEICE_NOT_CONNECT,/**<设备连接 */
    WHBLE_RESULT_NOT_SUPPORT_BLE,/**<不支持BLE */
    WHBLE_RESULT_BLUETOOTH_NOT_OPEN,/**<蓝牙未启动 */
    WHBLE_RESULT_OUTTIME,/**<接口调用超时 */
    WHBLE_RESULT_SEVEICE_NOT_USE_OR_SERVICE_NOT_EXIST,/**<服务未启动或门禁不存在此ServiceId */
    WHBLE_RESULT_INPUT_ERROR,/**<输入参数错误 */
    WHBLE_RESULT_NO_MATCH_DEVEICE,/**<门禁服务未找到 */
    WHBLE_RESULT_NOT_FOUND_SEVEICE,/**<门禁服务未找到 */
    WHBLE_RESULT_CHECKCODE_ERROR,/**<校验码错误 */
    WHBLE_RESULT_DEVEICE_NOT_ONLINE = 91,/**<设备不在线 */
    WHBLE_RESULT_REQUESTOR_NOT_ONLINE,/**<请求端不在线 */
    WHBLE_RESULT_NO_MATCH_SESSION_OBJECT,/**<没有对应session对象 */
    WHBLE_RESULT_NO_MATCH_SESSION,/**<没有对应session */
    WHBLE_RESULT_SESSION_NOT_CONNECT,/**<session未连接 */
    WHBLE_RESULT_HOST_NOT_RETURN,/**<主机未回复 */
    
};

/*!
 *   ErrorType  本地错误
 *
 */
typedef NS_ENUM(NSUInteger, ErrorType) {
    INPUT_ERROR_PWD = 0,/**<密码为固定8位 */
    INPUT_ERROR_DISCONNECTTIME,/**<自动断开时间数值范围20-255 */
    INPUT_ERROR_TXPOWER,/**<设备发送功率0-3 */
    INPUT_ERROR_ACTIVETIME,/**<输出保持时间10-100 */
    INPUT_ERROR_CONFIGBIT,/**<配置位0-3 */
    INPUT_ERROR_NEWPWD,/**<密码为固定8位 */
    INPUT_ERROR_NEWNAME,/**<设备名为固定4位 */
    INPUT_ERROR_CLOSETIME,/**<开门保持时间0-10 */
    INPUT_ERROR_VERSIONTYPE,/**<版本类型 */
    INPUT_ERROR_CARDID,/**<新增或删除的卡片ID错误 */
    INPUT_ERROR_CARD_COUNT,/**<新增或删除的卡片count错误,最大99个 */
    INPUT_ERROR_SERVERIP,/**<服务器IP输入错误 */
    INPUT_ERROR_HEART_BEAT,/**<心跳包输入错误 */
    ERROR_RETURN_WRONG_LENGTH_CHARACTERISTIC_VALUE,/**<写值返回长度错误或为空的特征值 */
    ERROR_WRITE_FAILED,/**<向蓝牙写入数据时发生错误 */
    ERROR_ACTION_OUTTIME,/**<请求超时 30s */
    
};

@protocol WHBleSearchDelegate <NSObject>
//搜索蓝牙的回调
-(void)bleDidDiscoverPeripherals:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;

@end

@protocol WHBleDelegate <NSObject>

@optional
//连接蓝牙的回调
-(void)bleDidConnectPeripheral:(CBPeripheral *)peripheral status:(ConnectStatus )status;
//一键开门回调
-(void)oneKeyOpenDeviceCallBack:(WHBleResultType)result;
//读取设备配置信息的回调
-(void)oneKeyReadDeviceConfigInfoCallBack:(WHBleResultType)result disConnectTime:(int)disConnectTime txPower:(WHBleTxPowerType)power activeTime:(int)actTime configBit:(int)configBit;
//设置配置信息的回调
-(void)oneKeySetDeviceConfigInfoCallBack:(WHBleResultType)result;
//更改设备密码的回调
-(void)oneKeyChangeDevPswCallBack:(WHBleResultType)result;
//更改设备名称的回调
-(void)oneKeyChangeDevNameCallBack:(WHBleResultType)result;
//一键开门带关闭时间的回调
-(void)oneKeyOpenDeviceWithTimeCallBack:(WHBleResultType)result;
//读取设备软件或硬件信息的回调
-(void)oneKeyReadVerInfoCallBack:(WHBleResultType)result verInfo:(NSString *)verInfo;
//读取设备内置时钟的回调，clockInfo 年月日或时分秒
-(void)oneKeyReadClockCallBack:(WHBleResultType)result clockInfo:(NSString *)clockInfo;
//设置时钟回调
-(void)oneKeySetClockCallBack:(WHBleResultType)result;
//增加密码/卡片回调
-(void)oneKeyAddPaswdAndCardKeyCallBack:(WHBleResultType)result;
//删除密码/卡片回调
-(void)oneKeyDeletePaswdAndCardKeyCallBack:(WHBleResultType)result;
//批量钥匙添加到falsh中回调
-(void)oneKeyFlashAddKeyCallBack:(WHBleResultType)result;
//批量删除钥匙回调
-(void)oneKeyFlashDeleteKeyCallBack:(WHBleResultType)result;
//配置门禁连接服务器IP回调
-(void)oneKeyConfigServerCallBack:(WHBleResultType)result;
//配置服务器门禁心跳
-(void)oneKeyServiceConfigDeviceCallBack:(WHBleResultType)result;

//错误回调
-(void)errorCallBack:(ErrorType)type;

@end

@interface WHBle : NSObject

//搜索代理
@property (nonatomic,assign) id<WHBleSearchDelegate> searchDelegate;

//蓝牙事件代理
@property (nonatomic,assign) id<WHBleDelegate> delegate;

/**
 * 单例构造方法
 * @return WHBle共享实例
 */
+ (instancetype)shareWHBle;
//蓝牙初始化
-(void)bleInit;
//蓝牙搜索,timeout超时时间
-(void)scanDevice:(int)timeout;
//停止搜索
-(void)stopSearch;
//连接设备
-(void)connectDeviece:(CBPeripheral *)peripheral;
//断开连接
- (void)disConnectDeviece:(CBPeripheral *)peripheral;
//断开所有连接
- (void)disConnectAllDevieces;
//一键开锁
-(void)oneKeyOpenDevice:(CBPeripheral *)peripheral password:(NSString *)pwd;
//读取设备配置信息
-(void)oneKeyReadDeviceConfigInfo:(CBPeripheral *)peripheral password:(NSString *)pwd;
/*!
 * 设置设备配置信息
 *
 * @param pwd 设备密码
 *
 * @param disConnect 自动断开连接时间，数值范围20-255
 *
 * @param txPower 蓝牙发送功率，默认为2 
 *
 * @param activeTime 输出保持时间,默认为:13,单位100ms,数值范围10-100,13表示13*100=1300ms
 *
 * @param configBit 配置位:默认0（0:韦根34小端 1:韦根34大端 2:韦根26小端 3:韦根26大端）
 *
 */
-(void)oneKeySetDeviceConfigInfo:(CBPeripheral *)peripheral password:(NSString *)pwd disConnectTime:(int)disConnect txPower:(WHBleTxPowerType)txPower activeTime:(int)activeTime configBit:(int)configBit;
//更改设备密码
-(void)oneKeyChangeDevPsw:(CBPeripheral *)peripheral password:(NSString *)pwd newPassword:(NSString *)nPwd;
//更改设备名称
-(void)oneKeyChangeDevName:(CBPeripheral *)peripheral password:(NSString *)pwd newDevieceName:(NSString *)nName;
/*!
 * 开锁指令（带关闭时间）
 *
 * @param pwd 设备密码
 *
 * @param cTime 保持时间，数值范围0-10秒
 *
 */
-(void)oneKeyOpenDevice:(CBPeripheral *)peripheral password:(NSString *)pwd withTime:(int )cTime;
//读取设备和软件的版本信息
-(void)oneKeyReadVerInfo:(CBPeripheral *)peripheral password:(NSString *)pwd versionType:(WHVersionType)vType;
//读取锁体中的时钟信息
-(void)oneKeyReadClock:(CBPeripheral *)peripheral password:(NSString *)pwd;
//设置更改锁体中时钟信息
-(void)oneKeySetClock:(CBPeripheral *)peripheral password:(NSString *)pwd clockStr:(NSString *)time type:(WHClockType)cType;
//增加密码/卡片到锁体中（适用于临时或者少量钥匙添加）
-(void)oneKeyAddPaswdAndCardKey:(CBPeripheral *)peripheral password:(NSString *)pwd cardID:(NSString *)cardID;
//删除锁体中密码/卡片（适用于删除临时或者少量钥匙）
-(void)oneKeyDeletePaswdAndCardKey:(CBPeripheral *)peripheral password:(NSString *)pwd cardID:(NSString *)cardID;
//增加密码/卡片到锁体中（适用于批量钥匙添加Flash中）
-(void)oneKeyFlashAddKey:(CBPeripheral *)peripheral password:(NSString *)pwd cardID:(NSString *)cardID count:(NSString *)count;
//删除锁体中密码/卡片（适用于删除批量钥匙）
-(void)oneKeyFlashDeleteKey:(CBPeripheral *)peripheral password:(NSString *)pwd cardID:(NSString *)cardID count:(NSString *)count;
//配置门禁连接的服务器IP信息 serverIP服务器IP
-(void)oneKeyConfigServer:(CBPeripheral *)peripheral password:(NSString *)pwd serverIP:(NSString *)serverIP;
//配置服务器门禁心跳  heartBeat心跳包
-(void)oneKeyServiceConfigDevice:(CBPeripheral *)peripheral password:(NSString *)pwd heartBeat:(NSString *)heartBeat;
@end
