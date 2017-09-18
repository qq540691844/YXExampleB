//
//  LYSearchItem.h
//  SYCFinance
//
//  Created by 房嘉星 on 17/8/16.
//  Copyright © 2017年 房嘉星. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+LYQuickControl.h"

@interface LYSearchItem : UIView
@property (nonatomic, strong) UILabel *leftLabel;           /**<左边名称*/
@property (nonatomic, strong) UITextField *contentTF;           /**<内容输入框*/
- (instancetype)initWithTitle:(NSString *)title;

- (instancetype)initWithPlaceholder:(NSString *)placeholder;
@end
