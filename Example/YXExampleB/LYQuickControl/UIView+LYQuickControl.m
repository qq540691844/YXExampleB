

#import "UIView+LYQuickControl.h"

@implementation UIView (LYQuickControl)

/**
 *  添加系统无图的按钮
 *
 *  @param title      标题
 *  @param color      标题颜色
 *  @param backcolor  背景颜色
 *  @param font       字体大小
 *  @param corner     圆角
 *  @param width      边框宽度
 *  @param boderColor 边框颜色
 *  @param action     action
 *
 *  @return UIButton
 */
- (UIButton *)addSystemButtonWithTitle:(NSString *)title
                            titleColor:(UIColor *)color
                       backgroundColor:(UIColor *)backcolor
                                  font:(UIFont *)font
                                corner:(CGFloat)corner
                             boderWide:(CGFloat)width
                            boderColor:(UIColor *)boderColor
                                action:( void (^)(UIButton *button))action {
    LYButton *button = [LYButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:color forState:UIControlStateNormal];
    [button setBackgroundColor:backcolor];
    button.layer.cornerRadius = corner;
    button.layer.borderWidth = width;
    button.layer.borderColor = boderColor.CGColor;
    button.clipsToBounds = YES;
    button.action = action;
    button.titleLabel.font=font;
    [self addSubview:button];
    return button;
}

/**
 *  添加小图或文字按钮
 *
 *  @param title      标题
 *  @param font       字体大小
 *  @param color      字体颜色
 *  @param backcolor  背景颜色
 *  @param image      左边的小图
 *  @param corner     圆角带下
 *  @param width      边框宽度
 *  @param boderColor 边框颜色
 *  @param action     action
 *
 *  @return UIButton
 */
- (UIButton *)addImageButtonWithtitle:(NSString *)title
                                 font:(UIFont *)font
                           titleColor:(UIColor *)color
                     bcackgroundColor:(UIColor *)backcolor
                            imageName:(NSString*)image
                               corner:(CGFloat)corner
                           boderWidth:(CGFloat)width
                           boderColor:(UIColor *)boderColor
                               action:( void (^)(UIButton *button) )action {
    LYButton *button = [LYButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:color forState:UIControlStateNormal];
    [button setBackgroundColor:backcolor];
    button.layer.cornerRadius = corner;
    button.layer.borderWidth = width;
    button.layer.borderColor = boderColor.CGColor;
    button.titleLabel.font = font;
    [button setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    button.clipsToBounds = YES;
    button.action = action;
    [self addSubview:button];
    return button;
    
}


/**
 *  添加背景大图或文字按钮
 *
 *  @param title      标题
 *  @param font       字体大小
 *  @param color      字体颜色
 *  @param backcolor  背景颜色
 *  @param image      背景图片
 *  @param corner     圆角大小
 *  @param width      边框宽度
 *  @param boderColor 边框颜色
 *  @param action     action
 *
 *  @return UIButton
 */
- (UIButton *)addBackgroundButtonWithTitle:(NSString *)title
                                      font:(UIFont *)font
                                titleColor:(UIColor *)color
                           backgroundColor:(UIColor *)backcolor
                                 imageName:(NSString *)image
                                    corner:(CGFloat)corner
                                 boderWide:(CGFloat)width
                                boderColor:(UIColor *)boderColor
                                    action:( void (^)(UIButton *button) )action {
    LYButton *button = [LYButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:color forState:UIControlStateNormal];
    [button setBackgroundColor:backcolor];
    button.layer.cornerRadius = corner;
    button.layer.borderWidth = width;
    button.layer.borderColor = boderColor.CGColor;
    button.titleLabel.font = font;
    [button setBackgroundImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    button.clipsToBounds = YES;
    button.action = action;
    [self addSubview:button];
    return button;
}


- (UIImageView *)addImageViewWithFrame:(CGRect)frame ImageName:(NSString *)name {
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:frame];
    imageView.image = [UIImage imageNamed:name];
    [self addSubview:imageView];
    return imageView;
}

/**
 *  添加文本控件
 *  @param text      文本内容
 *  @param teColor   颜色
 *  @param font      字体大小
 *  @param textAL    对齐方式
 *
 *  @return UILabel
 */
- (UILabel *)addLabelWithText:(NSString *)text
                    textColor:(UIColor *)teColor
                         font:(UIFont *)font
                textAlignment:(NSTextAlignment)textAL {
    UILabel *label=[[UILabel alloc] init];
    label.text = text;
    label.textColor = teColor;
    label.font = font;
    label.textAlignment = textAL;
    label.userInteractionEnabled = YES;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    [self addSubview:label];
    return label;
}

/**
 *  添加可点击的文本控件
 *
 *  @param text      文本内容
 *  @param teColor   字体颜色
 *  @param font      字体大小
 *  @param textAL    对齐方式
 *  @param action    action
 *
 *  @return UILabel
 */
- (UILabel *)addTapLabelWithText:(NSString *)text
                       textColor:(UIColor *)teColor
                            font:(UIFont *)font
                   textAlignment:(NSTextAlignment)textAL
                          action:( void (^)(LYLabel *label) )action {
    LYLabel *label=[[LYLabel alloc] init];
    label.text = text;
    label.textColor = teColor;
    label.font = font;
    label.textAlignment = textAL;
    label.userInteractionEnabled = YES;
    label.action = action;
    [self addSubview:label];
    return label;
}

- (UIView *)addLineViewWithColor:(UIColor *)color {
    UIView *view = [UIView new];
    view.backgroundColor = color;
    [self addSubview:view];
    return view;
}

@end
