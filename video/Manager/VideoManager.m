//
//  VideoManager.m
//  video
//
//  Created by butter on 2019/9/5.
//  Copyright © 2019 butter. All rights reserved.
//

#import "VideoManager.h"

@implementation VideoManager

+ (instancetype)defaultVideoManager {
    static VideoManager *defaultVideoManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultVideoManager = [[VideoManager alloc] init];
    });
    return defaultVideoManager;
}


@end
