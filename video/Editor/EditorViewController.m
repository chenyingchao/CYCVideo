//
//  EditorViewController.m
//  video
//
//  Created by butter on 2019/9/4.
//  Copyright © 2019 butter. All rights reserved.
//

#import "EditorViewController.h"
#import "BackgroundElement.h"
#import "EditorTool.h"

@interface EditorViewController ()

@property (nonatomic, strong) EditorTool *tool;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) BackgroundElement *backgroundElement;

@end

#define kContextWidth 340

#define kContextHeight 600

@implementation EditorViewController

- (void)loadView {
    [super loadView];
    [self initUI];
}

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)startEditor:(BaseElement *)element {
    [self.tool show];

}

- (void)initUI {
    
    [self.scrollView borderForColor:COLOR_FROM_RGB(0xcccccc) borderWidth:1 borderType:UIBorderSideTypeAll];
    [self.view addSubview:self.scrollView];
    
    self.scrollView.bounds = CGRectMake(0, 0, kContextWidth, kContextHeight);
    self.scrollView.center = CGPointMake(kDeviceWidth / 2, kDeviceHeight / 2);

    [self.scrollView addSubview:self.backgroundElement];
    [self updateContentSize:[UIImage imageNamed:@"bgDef"]];
    
}

- (void)updateContentSize:(UIImage *)contentImage {
    
    CGFloat width = contentImage.size.width * 1.5;
    CGFloat height = contentImage.size.height * 1.5;
    
    self.scrollView.contentSize = CGSizeMake(width, height);
    
    CGFloat offsetX = 0;
    if ((width - kContextWidth) > 0) {
        offsetX = (width - kContextWidth) / 2;
    }
    
    self.scrollView.contentOffset = CGPointMake(offsetX, 0);
    
    self.backgroundElement.imageView.image = contentImage;
    self.backgroundElement.bounds = CGRectMake(0, 0, contentImage.size.width, contentImage.size.height);
    self.backgroundElement.center = CGPointMake(width / 2, height / 2);
    
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    }
    return _scrollView;
}

- (BackgroundElement *)backgroundElement {
    if (!_backgroundElement) {
        _backgroundElement = [[BackgroundElement alloc] initWithFrame:CGRectZero];
        __weak __typeof__(self) weakSelf = self;
        _backgroundElement.editorBlcok = ^(BaseElement * _Nonnull element) {
            [weakSelf startEditor:element];
        };
    }
    return _backgroundElement;
}

- (EditorTool *)tool {
    if (!_tool) {
        _tool = [[EditorTool alloc] initWithFrame:CGRectMake(0, 0, kDeviceWidth, kDeviceHeight)];
    }
    return _tool;
}

@end
