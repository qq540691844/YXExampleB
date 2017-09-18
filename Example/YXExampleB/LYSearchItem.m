//
//  LYSearchItem.m
//  SYCFinance
//
//  Created by 房嘉星 on 17/8/16.
//  Copyright © 2017年 房嘉星. All rights reserved.
//

#import "LYSearchItem.h"


@interface LYSearchItem ()<UITextFieldDelegate>
@property (nonatomic, strong) UIView *line;           /**<底部线*/
@end

@implementation LYSearchItem

- (instancetype)initWithTitle:(NSString *)title{
    
    if (self = [super init]) {
    
        self.backgroundColor = [UIColor whiteColor];
        
        self.leftLabel = [self addLabelWithText:title textColor:[UIColor blackColor] font:[UIFont boldSystemFontOfSize:12] textAlignment:NSTextAlignmentCenter];
        
        self.contentTF = [UITextField new];
        self.contentTF.placeholder = @"请输入";
        self.contentTF.font = [UIFont systemFontOfSize:12];
        self.contentTF.textColor = [UIColor darkGrayColor];
        self.contentTF.textAlignment=NSTextAlignmentCenter;
        self.contentTF.returnKeyType=UIReturnKeyDone;
        self.contentTF.delegate=self;
        [self addSubview:self.contentTF];
        
        
        self.line = [self addLineViewWithColor:[UIColor blackColor]];
        
        // 左边名称文本
        [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self);
            make.left.mas_equalTo(self.mas_left);
            make.width.mas_equalTo(self.mas_width).multipliedBy(0.4);
        }];
        
        // 内容输入框
        [self.contentTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self);
            make.left.mas_equalTo(self.leftLabel.mas_right);
            make.width.mas_equalTo(self.mas_width).multipliedBy(0.6);
        }];
        
        // 底部的线
        [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self);
            make.left.mas_equalTo(self.contentTF).offset(-5);
            make.right.mas_equalTo(self).offset(-5);
            make.height.mas_equalTo(@0.5);
        }];
        
    }
    return self;
}

- (instancetype)initWithPlaceholder:(NSString *)placeholder{
    
    if (self = [super init]) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        self.contentTF = [UITextField new];
        self.contentTF.placeholder = placeholder;
        self.contentTF.font = [UIFont systemFontOfSize:12];
        self.contentTF.textColor = [UIColor darkGrayColor];
        self.contentTF.textAlignment=NSTextAlignmentCenter;
        self.contentTF.returnKeyType=UIReturnKeyDone;
        self.contentTF.delegate=self;
        [self addSubview:self.contentTF];
        
        
        self.line = [self addLineViewWithColor:[UIColor blackColor]];
        
        // 内容输入框
        [self.contentTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self);
            make.left.mas_equalTo(self);
            make.width.mas_equalTo(self.mas_width);
        }];
        
        // 底部的线
        [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self);
            make.left.mas_equalTo(self).offset(5);
            make.right.mas_equalTo(self).offset(-5);
            make.height.mas_equalTo(@0.5);
        }];
        
    }
    return self;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self endEditing:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self endEditing:YES];
    return YES;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
