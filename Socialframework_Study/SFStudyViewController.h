//
//  SFStudyViewController.h
//  Socialframework_Study
//
//  Created by 黒田 樹 on 2013/01/12.
//  Copyright (c) 2013年 黒田 樹. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFStudyViewController : UIViewController<UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *trackImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *albumLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectedAccountName;
- (IBAction)tweet:(id)sender;
- (IBAction)postWall:(id)sender;
- (IBAction)reverseAuth:(id)sender;
- (IBAction)tweetUsingSLRequest:(id)sender;
- (IBAction)showTwitterAccounts:(id)sender;
- (IBAction)showFacebookAccounts:(id)sender;

@end
