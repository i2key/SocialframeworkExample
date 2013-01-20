//
//  UIAlertViewWithoutDelegate.h
//  Socialframework_Study
//
//  Created by 黒田 樹 on 2013/01/15.
//  Copyright (c) 2013年 黒田 樹. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIAlertViewWithoutDelegate: UIAlertView {
    void    (^_completionHandler)(NSInteger buttonIndex);
}
- (void)showWithCompletionHandler:(void(^)(NSInteger buttonIndex))_completionHandler;
@end
