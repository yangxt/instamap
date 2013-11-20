//
//  LoginViewController.m
//  instamap
//
//  Created by Andrei Rozhkov on 19.11.13.
//  Copyright (c) 2013 Andrei Rozhkov. All rights reserved.
//

#import "LoginViewController.h"
#import "InstaClient.h"

@interface LoginViewController ()
{
    NSString* accessToken;
}

@end

@implementation LoginViewController

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
    
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView;
{
    [super loadView];
    
    NSURLRequest* request =
    [NSURLRequest requestWithURL:[NSURL URLWithString:
                                  [NSString stringWithFormat:kAuthenticationEndpoint, kClientId, kRedirectUrl]]];
    [self.webView loadRequest:request];
    
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.absoluteString rangeOfString:@"#"].location != NSNotFound) {
        
        NSString* params = [[request.URL.absoluteString componentsSeparatedByString:@"#"] objectAtIndex:1];
        accessToken = [params stringByReplacingOccurrencesOfString:@"access_token=" withString:@""];
        
        // Save access_token
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:accessToken] forKey:@"Access_token"];
        
        [self performSegueWithIdentifier:@"login" sender:nil];

        return NO;
    }
    
	return YES;
}

@end
