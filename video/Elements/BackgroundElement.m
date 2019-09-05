//
//  BackgroundElement.m
//  video
//
//  Created by butter on 2019/9/5.
//  Copyright © 2019 butter. All rights reserved.
//

#import "BackgroundElement.h"

@interface BackgroundElement ()



@end

@implementation BackgroundElement

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.imageView];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        
    }
    
    return self;
}





@end
