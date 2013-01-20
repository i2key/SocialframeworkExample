//
//  ACAccountDetailViewController.m
//  Socialframework_Study
//
//  Created by 黒田 樹 on 2013/01/20.
//  Copyright (c) 2013年 黒田 樹. All rights reserved.
//

#import "ACAccountDetailViewController.h"
#import <Social/Social.h>
#import "TWSignedRequest.h"
#import "SVProgressHUD.h"
#import "UIAlertViewWithoutDelegate.h"


#define TW_X_AUTH_MODE_KEY                  @"x_auth_mode"
#define TW_X_AUTH_MODE_REVERSE_AUTH         @"reverse_auth"
#define TW_X_AUTH_REVERSE_PARMS             @"x_reverse_auth_parameters"
#define TW_X_AUTH_REVERSE_TARGET            @"x_reverse_auth_target"
#define TW_OAUTH_URL_REQUEST_TOKEN          @"https://api.twitter.com/oauth/request_token"
#define TW_OAUTH_URL_AUTH_TOKEN             @"https://api.twitter.com/oauth/access_token"

@interface ACAccountDetailViewController ()

@end

@implementation ACAccountDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewDidLoad];
    
    if ([ACAccountTypeIdentifierTwitter isEqual:[[self.selectedAccount accountType] identifier] ]) {
        [self.reverseAuthBtn setHidden:NO];
    }else{
        [self.reverseAuthBtn setHidden:YES];
    }
    
    [self.accountTypeLabel setText:[[self.selectedAccount accountType] accountTypeDescription]];
    [self.userNameLabel setText:[self.selectedAccount username]];
    ACAccountCredential *credential = [self.selectedAccount credential];
    [self.oauthTokenTextView setText:[credential oauthToken]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                        NSLog(@"AuthData : %@",responseStr);
                        
                        [self performSelectorOnMainThread:@selector(showAlert:) withObject:responseStr waitUntilDone:YES];
 					}
				}];
			});
		}
	}];
}

- (void)showAlert:(NSString *)message
{
    UIAlertViewWithoutDelegate *alertView = [[UIAlertViewWithoutDelegate alloc] initWithTitle:@"Alert"
                                                                                      message:message
                                                                                     delegate:nil
                                                                            cancelButtonTitle:@"cancel"
                                                                            otherButtonTitles:@"ok", nil];
    [alertView showWithCompletionHandler:^(NSInteger buttonIndex) {
        // Do something.
    }];
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

- (IBAction)pushCloseBtn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
