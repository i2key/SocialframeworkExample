//
//  SFStudyViewController.m
//  Socialframework_Study
//
//  Created by 黒田 樹 on 2013/01/12.
//  Copyright (c) 2013年 黒田 樹. All rights reserved.
//

#import "SFStudyViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "ACAccountDetailViewController.h"
#import "MusicManager.h"



#define BTN_TITLE_CANCEL                    @"Cancel"

@interface SFStudyViewController ()
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) NSArray *accounts;
@property (nonatomic, strong) ACAccount *selectedAccount;
@property (nonatomic, assign) NSUInteger twitterAccountIndex;
@end

@implementation SFStudyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.accountStore = [[ACAccountStore alloc] init];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //バックグラウンドからの復帰タイミングでプレーヤ画面を更新するために通知センターを使う
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(recievedNotification:)
                   name:UIApplicationWillEnterForegroundNotification
                 object:nil];
    
    [self updatePlayingInfo];
}

-(void)viewWillDisappear:(BOOL)animated{
    //Observerがたまってしまうため、disapearタイミングで解放
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SLComposeViewController Sample
- (IBAction)tweet:(id)sender {
    SLComposeViewController *twitterPostVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [twitterPostVC setInitialText:[[MusicManager sharedManager] createShareMessage]];
    [twitterPostVC addImage:[[MusicManager sharedManager] trackImage]];
    [self presentViewController:twitterPostVC animated:YES completion:nil];
}

- (IBAction)postWall:(id)sender {
    SLComposeViewController *facebookPostVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [facebookPostVC setInitialText:[[MusicManager sharedManager] createShareMessage]];
    [facebookPostVC addImage:[[MusicManager sharedManager] trackImage]];
    [self presentViewController:facebookPostVC animated:YES completion:nil];
}

#pragma mark - ACAccount Sample
- (IBAction)showTwitterAccounts:(id)sender {
	ACAccountType *twitterType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [self.accountStore requestAccessToAccountsWithType:twitterType options:Nil completion:^(BOOL granted, NSError *error) {
        if (granted) {
			NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(showActionSheet:) object:twitterType];
			[thread start];
		}
    }];
    
}

- (IBAction)showFacebookAccounts:(id)sender {
    ACAccountType *facebookType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];

    NSDictionary *options = @{ACFacebookAppIdKey : @"325268504258425",
                        ACFacebookPermissionsKey : @[@"email"],
                           ACFacebookAudienceKey : ACFacebookAudienceOnlyMe};

    [self.accountStore requestAccessToAccountsWithType:facebookType options:options completion:^(BOOL granted, NSError *error) {
        if(granted){
            NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(showActionSheet:) object:facebookType];
            [thread start];
        }else{
            NSLog(@"error:%@",[error description]);
        }
     }];
        
}

- (void)showActionSheet :(ACAccountType*)serviceType
{
	self.accounts = [self.accountStore accountsWithAccountType:serviceType];
    UIActionSheet *actionSheet = [[UIActionSheet alloc]init];
    actionSheet.delegate = self;
    [actionSheet setTitle:@"Select account"];
    for (ACAccount *account in self.accounts) {
        [actionSheet addButtonWithTitle:[account username]];
    }
    [actionSheet setCancelButtonIndex:[actionSheet addButtonWithTitle:BTN_TITLE_CANCEL]];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:BTN_TITLE_CANCEL]) {
		return;
	}
    self.selectedAccount = [self.accounts objectAtIndex:buttonIndex];
    [_selectedAccountName setText:[self.selectedAccount username]];
    
    [self showModalScreen];
}

- (void)showModalScreen{
    ACAccountDetailViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ACAccountDetailViewController"];
    [destVC setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    destVC.selectedAccount = self.selectedAccount;
    [self presentViewController:destVC animated:YES completion:nil];
}

#pragma mark - mediaPlayer
-(void)updatePlayingInfo{
    [_trackImageView setImage:[[MusicManager sharedManager] trackImage]];
    [_titleLabel setText:[[MusicManager sharedManager] title]];
    [_albumLabel setText:[[MusicManager sharedManager] album]];
    [_artistLabel setText:[[MusicManager sharedManager] artist]];
}

#pragma mark - notificationCenter
-(void)recievedNotification:(NSNotification*)notification{
    [self updatePlayingInfo];
}



@end
