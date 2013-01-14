//
//  SFStudyViewController.m
//  Socialframework_Study
//
//  Created by 黒田 樹 on 2013/01/12.
//  Copyright (c) 2013年 黒田 樹. All rights reserved.
//

#import "SFStudyViewController.h"
#import "TWSignedRequest.h"
#import <MediaPlayer/MediaPlayer.h>
#import <Social/Social.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "SVProgressHUD.h"

#define TW_X_AUTH_MODE_KEY                  @"x_auth_mode"
#define TW_X_AUTH_MODE_REVERSE_AUTH         @"reverse_auth"
#define TW_X_AUTH_REVERSE_PARMS             @"x_reverse_auth_parameters"
#define TW_X_AUTH_REVERSE_TARGET            @"x_reverse_auth_target"
#define TW_OAUTH_URL_REQUEST_TOKEN          @"https://api.twitter.com/oauth/request_token"
#define TW_OAUTH_URL_AUTH_TOKEN             @"https://api.twitter.com/oauth/access_token"

#define BTN_TITLE_CANCEL                    @"Cancel"

@interface SFStudyViewController (){
    MPMusicPlayerController *player;
}
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
    MPMediaItem *item = [self getPlayingItem];
	MPMediaItemArtwork *artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
    
    SLComposeViewController *twitterPostVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [twitterPostVC setInitialText:[self createShareMessage]];
    [twitterPostVC addImage:[artwork imageWithSize:CGSizeMake(320, 320)]];
    [self presentViewController:twitterPostVC animated:YES completion:nil];
}

- (IBAction)postWall:(id)sender {
    MPMediaItem *item = [self getPlayingItem];
	MPMediaItemArtwork *artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
    
    SLComposeViewController *facebookPostVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [facebookPostVC setInitialText:[self createShareMessage]];
    [facebookPostVC addImage:[artwork imageWithSize:CGSizeMake(320, 320)]];
    [self presentViewController:facebookPostVC animated:YES completion:nil];
}

#pragma mark - ACAccount Sample
- (IBAction)showTwitterAccounts:(id)sender {
    self.accountStore = [[ACAccountStore alloc] init];
	ACAccountType *twitterType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [self.accountStore requestAccessToAccountsWithType:twitterType options:Nil completion:^(BOOL granted, NSError *error) {
        if (granted) {
			NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(showActionSheet:) object:twitterType];
			[thread start];
		}
    }];
}

- (IBAction)showFacebookAccounts:(id)sender {
    self.accountStore = [[ACAccountStore alloc] init];
    ACAccountType *facebookType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"325268504258425", ACFacebookAppIdKey,
                             //[NSArray arrayWithObjects:@"public_actions", @"publish_stream", @"offline_access", nil], ACFacebookPermissionsKey,
                             [NSArray arrayWithObjects:@"email",nil], ACFacebookPermissionsKey,
                             ACFacebookAudienceOnlyMe, ACFacebookAudienceKey,
                             nil];
    [self.accountStore requestAccessToAccountsWithType:facebookType options:options completion:^(BOOL granted, NSError *error) {
        if(granted){
            NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(showActionSheet:) object:facebookType];
            [thread start];
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
}

#pragma mark - SLRequest Sample
- (IBAction)tweetUsingSLRequest:(id)sender {
    if(self.selectedAccount == Nil){
        return;
    }
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        NSURL *url = [NSURL URLWithString:@"http://api.twitter.com/1.1/statuses/update_with_media.json"];
        NSDictionary *params = [NSDictionary dictionaryWithObject:[self createShareMessage] forKey:@"status"];
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                requestMethod:SLRequestMethodPOST
                                                          URL:url
                                                   parameters:params];

        NSData *imageData=UIImagePNGRepresentation([self getPlayingTrackImage]);
        [request addMultipartData:imageData withName:@"media[]" type:@"multipart/form-data" filename:@"hoge"];
        
        [request setAccount:self.selectedAccount];
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            NSLog(@"responseData=%@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
        }];
    }
}

#pragma mark - ReverseAuth Sample
- (IBAction)reverseAuth:(id)sender {
    //  Step 1)  Ask Twitter for a special request_token for reverse auth
	NSURL *url = [NSURL URLWithString:TW_OAUTH_URL_REQUEST_TOKEN];
	
	// "reverse_auth" is a required parameter
	NSDictionary *dict = [NSDictionary dictionaryWithObject:TW_X_AUTH_MODE_REVERSE_AUTH forKey:TW_X_AUTH_MODE_KEY];
	TWSignedRequest *signedRequest = [[TWSignedRequest alloc] initWithURL:url parameters:dict requestMethod:TWSignedRequestMethodPOST];
	
	[self showProgress];
	[signedRequest performRequestWithHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		if (!data) {
			[self dismissProgress:@"Error occurred in Step 1."];
		}
		else {
			NSString *signedReverseAuthSignature = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			
			//  Step 2)  Ask Twitter for the user's auth token and secret
			//           include x_reverse_auth_target=CK2 and x_reverse_auth_parameters=signedReverseAuthSignature parameters
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				NSDictionary *step2Params = [NSDictionary dictionaryWithObjectsAndKeys:[TWSignedRequest consumerKey], TW_X_AUTH_REVERSE_TARGET, signedReverseAuthSignature, TW_X_AUTH_REVERSE_PARMS, nil];
				NSURL *authTokenURL = [NSURL URLWithString:TW_OAUTH_URL_AUTH_TOKEN];
                
                //-- iOS5 -----
				//TWRequest *step2Request = [[TWRequest alloc] initWithURL:authTokenURL parameters:step2Params requestMethod:TWRequestMethodPOST];
                //-------------
                //-- iOS6 -----
				SLRequest *step2Request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:authTokenURL parameters:step2Params];
                //-------------
                
				[step2Request setAccount:self.selectedAccount];
                //[step2Request setAccount:[self.accounts objectAtIndex:_twitterAccountIndex]];
				[step2Request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
					if (!responseData || ((NSHTTPURLResponse*)response).statusCode >= 400) {
						[self dismissProgress:@"Error occurred in Step 2."];
					} else {
                        [self dismissProgress:nil];
                        
						NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
						//[[NSUserDefaults standardUserDefaults] setObject:responseStr forKey:@"authData"];
						//[self sendAuthData:responseStr loginWebView:nil];
                        NSLog(@"AuthData : %@",responseStr);
					}
				}];
			});
		}
	}];
}

#pragma mark - mediaPlayer
-(void)updatePlayingInfo{
    MPMediaItem *item = [self getPlayingItem];
	MPMediaItemArtwork *artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
    [_trackImageView setImage:[artwork imageWithSize:CGSizeMake(320, 320)]];
    [_titleLabel setText:[item valueForProperty:MPMediaItemPropertyTitle]];
    [_albumLabel setText:[item valueForProperty:MPMediaItemPropertyAlbumTitle]];
    [_artistLabel setText:[item valueForProperty:MPMediaItemPropertyArtist]];
}

-(MPMediaItem *)getPlayingItem{
    if(player == nil){
        player = [MPMusicPlayerController iPodMusicPlayer];
    }
    return [player nowPlayingItem];
}

-(NSString *)createShareMessage{
    MPMediaItem *item = [self getPlayingItem];
    return [NSString stringWithFormat:@"%@ の %@ を聴いています",[item valueForProperty:MPMediaItemPropertyArtist],[item valueForProperty:MPMediaItemPropertyTitle]];
}

-(UIImage *)getPlayingTrackImage{
    MPMediaItem *item = [self getPlayingItem];
	MPMediaItemArtwork *artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
    return [artwork imageWithSize:CGSizeMake(320, 320)];
}

#pragma mark - notificationCenter
-(void)recievedNotification:(NSNotification*)notification{
    [self updatePlayingInfo];
}

#pragma mark - SVProgressHUD
- (void) showProgress {
	[SVProgressHUD show];
}

- (void)dismissProgress: (NSString*)errorBody {
	if (errorBody != nil && ![errorBody isEqual:[NSNull null]] && [errorBody length] > 0) {
		[SVProgressHUD dismissWithError:errorBody];
	} else {
		[SVProgressHUD dismiss];
	}
}


@end
