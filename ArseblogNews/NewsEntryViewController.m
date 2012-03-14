//
//  NewsEntryViewController.m
//  ArseblogNews
//
//  Created by Adam Lum on 1/16/12.
//  Copyright (c) 2012 Adam Lum. All rights reserved.
//

#import "NewsEntryViewController.h"
#import "Reachability.h"

@interface NewsEntryViewController()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation NewsEntryViewController

@synthesize webView = _webView;
@synthesize newsEntry = _newsEntry;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamed: @"arseblog_logo.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
    self.navigationItem.titleView = imageView;
    self.webView.delegate = self;
    
    Reachability *reach = [Reachability reachabilityWithHostname:@"publicaccessgolf.com.au"];
    
    reach.reachableBlock = ^(Reachability *reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.webView loadHTMLString:self.newsEntry.entryContent baseURL:[NSURL URLWithString:@"http://news.arseblog.com"]];
        });
        [reachability stopNotifier];
    };
    
    reach.unreachableBlock = ^(Reachability *reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSRegularExpression *removeImageFromDescription = [[NSRegularExpression alloc] initWithPattern:@"<img (.+) />" options:NSRegularExpressionCaseInsensitive error:nil];
            NSString *contentWithoutImages = [removeImageFromDescription stringByReplacingMatchesInString:self.newsEntry.entryContent options:0 range:NSMakeRange(0, [self.newsEntry.entryContent length]) withTemplate:@""];
            [self.webView loadHTMLString:contentWithoutImages baseURL:[NSURL URLWithString:@"http://news.arseblog.com"]];
            
        });
        [reachability stopNotifier];
    };
    
    [reach startNotifier];
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    
    return YES;
}

@end
