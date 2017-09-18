

#import "LYButton.h"

@implementation LYButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]){
        [self addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}
- (void)btnClick:(UIButton *)button {
    if(self.action) {
        self.action(self);
    }
}

@end
