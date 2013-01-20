//
//  ACAccountDetailViewController.h
//  Socialframework_Study
//
//  Created by 黒田 樹 on 2013/01/20.
//  Copyright (c) 2013年 黒田 樹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>

@interface ACAccountDetailViewController : UIViewController
- (IBAction)pushCloseBtn:(id)sender;

@property(nonatomic,strong) ACAccount *selectedAccount;
@property (weak, nonatomic) IBOutlet UILabel *accountTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *oauthTokenTextView;

@end
