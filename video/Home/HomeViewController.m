//
//  HomeViewController.m
//  video
//
//  Created by butter on 2019/9/4.
//  Copyright © 2019 butter. All rights reserved.
//

#import "HomeViewController.h"
#import "EditorViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    EditorViewController *editorVC = [[EditorViewController alloc] init];
    [self.navigationController pushViewController:editorVC animated:YES];
}



@end
