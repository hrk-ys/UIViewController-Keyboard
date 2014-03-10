//
//  UIViewController+Keyboard.h
//  UIViewController+KeyboardDemo
//
//  Created by Hiroki Yoshifuji on 2014/03/10.
//  Copyright (c) 2014年 Hiroki Yoshifuji. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Keyboard)

@property (nonatomic) BOOL enableKeyboardResize;
+(void)setupKeyboardResize;

@end
