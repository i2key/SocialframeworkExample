//
//  ACAccountDetailViewController.m
//  Socialframework_Study
//
//  Created by 黒田 樹 on 2013/01/20.
//  Copyright (c) 2013年 黒田 樹. All rights reserved.
//

#import "ACAccountDetailViewController.h"

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

- (IBAction)pushCloseBtn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
