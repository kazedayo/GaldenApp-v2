//
//  UIKeyboard.m
//  GaldenApp
//
//  Created by Kin Wa Lam on 30/4/2019.
//  Copyright © 2019 1080@galden. All rights reserved.
//

#import "UIKeyboard.h"
#import <objc/runtime.h>

@implementation UIKeyboard

// Allows the changing of keyboard styles
static UIKeyboardAppearance keyboardStyle;

// Leave this as an instance method
- (UIKeyboardAppearance)keyboardAppearance {
    return keyboardStyle;
}

// This can be a class method
+ (void)setStyle:(UIKeyboardAppearance)style on:(UIWebView *)webView {
    for (UIView *view in [[webView scrollView] subviews]) {
        if([[view.class description] containsString:@"UI"] && [[view.class description] containsString:@"Web"] && [[view.class description] containsString:@"Browser"] && [[view.class description] containsString:@"View"]) {
            UIView *content = view;
            NSString *className = [NSString stringWithFormat:@"%@_%@",[[content class] superclass],[self class]];
            Class newClass = NSClassFromString(className);
            if (!newClass) {
                newClass = objc_allocateClassPair([content class], [className cStringUsingEncoding:NSASCIIStringEncoding], 0);
                Method method = class_getInstanceMethod([UIKeyboard class], @selector(keyboardAppearance));
                class_addMethod(newClass, @selector(keyboardAppearance), method_getImplementation(method), method_getTypeEncoding(method));
                objc_registerClassPair(newClass);
            }
            object_setClass(content, newClass);
            keyboardStyle = style;
            return;
        }
    }
}

@end
