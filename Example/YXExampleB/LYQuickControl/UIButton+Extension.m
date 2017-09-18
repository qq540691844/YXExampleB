

#import "UIButton+Extension.h"
#import "UIImage+Extension.h"

@implementation UIButton (Extension)
- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state {
    
    UIImage *backgroundImage = [UIImage imageWithColor:backgroundColor size:CGSizeMake(1, 1)];
    self.imageView.contentMode = UIViewContentModeScaleToFill;
    [self setBackgroundImage:backgroundImage forState:state];
}
@end
