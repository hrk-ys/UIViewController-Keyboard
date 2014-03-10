//
//  UIViewController+Keyboard.m
//  UIViewController+KeyboardDemo
//
//  Created by Hiroki Yoshifuji on 2014/03/10.
//  Copyright (c) 2014年 Hiroki Yoshifuji. All rights reserved.
//

#import "UIViewController+Keyboard.h"

#import <objc/runtime.h>

@implementation UIViewController (Keyboard)

static char enableKeyboardResizeKey;

- (BOOL)enableKeyboardResize
{
    return [objc_getAssociatedObject(self, &enableKeyboardResizeKey) boolValue];
}

- (void)setEnableKeyboardResize:(BOOL)enableKeyboardResize
{
    objc_setAssociatedObject(self, &enableKeyboardResizeKey, @(enableKeyboardResize), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static void swizzInstance(Class class, SEL originalSel, SEL newSel)
{
    Method origMethod = class_getInstanceMethod(class, originalSel);
    Method newMethod  = class_getInstanceMethod(class, newSel);
    
    method_exchangeImplementations(origMethod, newMethod);
}

+ (void)setupKeyboardResize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        swizzInstance([self class], @selector(viewDidAppear:), @selector(keyboard_viewDidAppear:));
        swizzInstance([self class], @selector(viewWillDisappear:), @selector(keyboard_viewWillDisappear:));
    });
}

- (void)keyboard_viewDidAppear:(BOOL)animated
{
    [self keyboard_viewDidAppear:animated];
    
    if (self.enableKeyboardResize) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [center addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
}

- (void)keyboard_viewWillDisappear:(BOOL)animated
{
    [self keyboard_viewWillDisappear:animated];
    
    if (self.enableKeyboardResize) {
        NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
        [center removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [center removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }
}
#pragma mark -
#pragma mark -- UIKeyboardWillShowNotification --

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    NSDictionary *userInfo = [aNotification userInfo];
    
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardTop  = keyboardRect.origin.y;
    CGRect  newViewFrame = self.view.frame;
    newViewFrame.size.height = keyboardTop - self.view.bounds.origin.y;
    
    UIViewAnimationCurve animationCurve = [[aNotification userInfo][UIKeyboardAnimationCurveUserInfoKey] integerValue];

    NSValue *animationDurationValue =
    [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView animateWithDuration:animationDuration
                          delay:0
                        options:(animationCurve << 16)
                     animations:^{
                         self.view.frame = newViewFrame;
                     } completion:^(BOOL finished) {
                     }];
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    CGRect keyboardRect =
    [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue
     ];
    keyboardRect = [[self.view superview] convertRect:keyboardRect fromView:nil];
    
    NSTimeInterval animationDuration =
    [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey]
     doubleValue];
    
    UIViewAnimationCurve animationCurve = [[aNotification userInfo][UIKeyboardAnimationCurveUserInfoKey] integerValue];

    CGRect frame = self.view.frame;
    frame.size.height = keyboardRect.origin.y;
    
    [UIView animateWithDuration:animationDuration
                          delay:0
                        options:(animationCurve << 16)
                     animations:^{
                         self.view.frame = frame;
                     } completion:^(BOOL finished) {
                     }];
}

@end
