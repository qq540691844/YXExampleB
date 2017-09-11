//
//  WHBleLib.h
//  WHBleLib
//
//  Created by admin on 2017/9/11.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WHBleLib : NSObject

//蓝牙初始化
-(void)bleInit;
//蓝牙搜索
-(void)scanDevice;

//-(void)oneKeyOpenDevice;

@end
