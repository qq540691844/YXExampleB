//
//  LYButton.h
//  LYCar
//
//  Created by 房嘉星 on 15/8/12.
//  Copyright (c) 2015年 ly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LYButton : UIButton
@property (copy,nonatomic) void (^action)(UIButton *button);
@end
