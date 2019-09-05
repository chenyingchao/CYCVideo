//
//  BaseElement.h
//  video
//
//  Created by butter on 2019/9/5.
//  Copyright © 2019 butter. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class BaseElement;
typedef void (^EditorBlock) (BaseElement *element);

@interface BaseElement : UIView

@property (nonatomic, copy) EditorBlock editorBlcok;

@end

NS_ASSUME_NONNULL_END
