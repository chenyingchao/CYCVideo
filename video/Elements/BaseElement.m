//
//  BaseElement.m
//  video
//
//  Created by butter on 2019/9/5.
//  Copyright © 2019 butter. All rights reserved.
//

#import "BaseElement.h"

@interface BaseElement ()

@property (nonatomic, strong) UITapGestureRecognizer *tapGes;

@end

@implementation BaseElement

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editor)];
        self.tapGes.numberOfTapsRequired = 2;
        [self addGestureRecognizer:self.tapGes];
        
        
    }
    return self;
}

- (void)editor {
    if (self.editorBlcok) {
        self.editorBlcok(self);
    }
}


@end
