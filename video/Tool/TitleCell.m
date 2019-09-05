//
//  titleCell.m
//  video
//
//  Created by butter on 2019/9/5.
//  Copyright © 2019 butter. All rights reserved.
//

#import "TitleCell.h"


@implementation TitleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        self.titleLabel.backgroundColor = COLOR_FROM_RGB(0xe2e2e2);
    }
    return self;
}

@end
