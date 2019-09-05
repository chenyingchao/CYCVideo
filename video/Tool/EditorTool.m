//
//  EditorTool.m
//  video
//
//  Created by butter on 2019/9/5.
//  Copyright © 2019 butter. All rights reserved.
//

#import "EditorTool.h"
#import "TitleCell.h"

@interface EditorTool ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *titles;

@end

@implementation EditorTool

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.tableView];

        self.titles = [@[] mutableCopy];
        [self.titles addObject:@"替换"];
        [self.titles addObject:@"滤镜"];
        [self.titles addObject:@"向上"];
        [self.titles addObject:@"向下"];
        
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([touches anyObject].view == self) {
        [self dismiss];
    }
}


- (void)show {
    [KeyWindow addSubview:self];
    [UIView animateWithDuration:0.25 animations:^{
        CGRect rect = self.tableView.frame;
        rect.origin.x = 0;
        self.tableView.frame = rect;
    }];
}

- (void)dismiss {
    
    [UIView animateWithDuration:0.25 animations:^{
        CGRect rect = self.tableView.frame;
        rect.origin.x = -60;
        self.tableView.frame = rect;
    } completion:^(BOOL finished) {
       [self removeFromSuperview];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titles.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TitleCell *cell = [[TitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"def"];
    cell.titleLabel.text = self.titles[indexPath.row];
    return cell;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(-60, 0, 60, self.frame.size.height) style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
      //  _tableView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    }
    return _tableView;
}



@end
