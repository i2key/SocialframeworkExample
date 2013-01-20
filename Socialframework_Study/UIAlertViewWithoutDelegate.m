//
//  UIAlertViewWithoutDelegate.m
//  Socialframework_Study
//
//  Created by 黒田 樹 on 2013/01/15.
//  Copyright (c) 2013年 黒田 樹. All rights reserved.
//

#import "UIAlertViewWithoutDelegate.h"

@implementation UIAlertViewWithoutDelegate
- (void)showWithCompletionHandler:(void(^)(NSInteger buttonIndex))completionHandler
{
    // completionHandler を copy し、アラートを表示する。
    _completionHandler = [completionHandler copy];
    [self show];
}
- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
    // アラートを閉じ、 _completionHandler を実行する。
    [super dismissWithClickedButtonIndex:buttonIndex animated:animated];
    _completionHandler(buttonIndex);
}
@end
