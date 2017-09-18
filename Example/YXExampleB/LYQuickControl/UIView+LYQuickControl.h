/**
 *  UIView+LYQuickControl.h
 *  @功能 快速创建常用控件，如button、label、view等控件
 *  @作者 fangjiaxing
 *  @日期 2016/11/30
 *  @修改记录
 *   暂无
 */

#import <UIKit/UIKit.h>
#import "LYLabel.h"
#import "LYButton.h"

@interface UIView (LYQuickControl)
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
                                action:( void (^)(UIButton *button))action;

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
                               action:( void (^)(UIButton *button) )action;


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
                                    action:( void (^)(UIButton *button) )action;


//添加图片控件
- (UIImageView *)addImageViewWithFrame:(CGRect)frame ImageName:(NSString *)name;


/**
 *  添加文本控件
 *
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
                textAlignment:(NSTextAlignment)textAL;

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
                          action:( void (^)(LYLabel *label) )action;


- (UIView *)addLineViewWithColor:(UIColor *)color;

@end
