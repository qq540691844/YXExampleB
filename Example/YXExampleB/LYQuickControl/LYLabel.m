

#import "LYLabel.h"

@implementation LYLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(LabelTap:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}
- (void)LabelTap:(UITapGestureRecognizer *)tap {
    
    if(self.action) {
        self.action(self);
    }
}

@end
