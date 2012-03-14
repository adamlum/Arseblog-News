//
//  ArseblogNewsTableViewController.m
//  ArseblogNews
//
//  Created by Adam Lum on 1/14/12.
//  Copyright (c) 2012 Adam Lum. All rights reserved.
//

#import "ArseblogNewsTableViewController.h"
#import "GDataXMLNode.h"
#import "GDataXMLElement-Extras.h"
#import "NSDate+InternetDateTime.h"
#import "NewsFetcher.h"
#import "NewsEntry+Create.h"
#import "Reachability.h"

#define  MAX_ARTICLE_COUNT 30

@interface ArseblogNewsTableViewController()

@property (strong, nonatomic) IBOutlet UIBarButtonItem *refresh;
@property (strong, nonatomic) UIManagedDocument *newsEntryDatabase;

- (void)parseRss:(GDataXMLElement *)rootElement entries:(NSMutableArray *)entries;
- (void)useDocument;

@end

@implementation ArseblogNewsTableViewController

@synthesize refresh = _refresh;
@synthesize newsEntryDatabase = _newsEntryDatabase;

- (void) setupFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"NewsEntry"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"entryDate" ascending:NO]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.newsEntryDatabase.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

- (void)setNewsEntryDatabase:(UIManagedDocument *)newsEntryDatabase
{
    if (_newsEntryDatabase != newsEntryDatabase)
    {
        _newsEntryDatabase = newsEntryDatabase;
    }
    [self useDocument];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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
    self.title = @"News";
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"News" style:UIBarButtonItemStyleBordered target:nil action:nil];
    newBackButton.tintColor = [UIColor colorWithRed:0.894417 green:0 blue:0.116158 alpha:1];
    self.navigationItem.backBarButtonItem = newBackButton;
}

- (void)viewDidUnload
{
    [self setRefresh:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.newsEntryDatabase)
    {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"newsEntryDatabase"];
        self.newsEntryDatabase = [[UIManagedDocument alloc] initWithFileURL:url];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NewsItemCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NewsEntry *entry = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = entry.title;
    cell.detailTextLabel.text = [[entry.entryDate descriptionWithLocale:nil] stringByAppendingFormat:@" | %@", entry.author];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.font = [UIFont fontWithName:cell.textLabel.font.fontName size:14];
    cell.detailTextLabel.font = [UIFont fontWithName:cell.detailTextLabel.font.fontName size:12];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (IBAction)refreshPressed:(id)sender
{
    Reachability *reach = [Reachability reachabilityWithHostname:@"news.arseblog.com"];
    
    reach.reachableBlock = ^(Reachability *reachability)
    {
        UIView *tempView = [[UIView alloc] initWithFrame:self.view.frame];
        tempView.backgroundColor = [UIColor colorWithRed:0.894417 green:0 blue:0.116158 alpha:1];
        tempView.alpha = 0.65;
        
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        UIBarButtonItem *spinnerButton = [[UIBarButtonItem alloc] initWithCustomView:spinner];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [spinner startAnimating];
            self.navigationItem.rightBarButtonItem = spinnerButton;
            [self.view addSubview:tempView];
        });
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error;
            GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:[NewsFetcher executeNewsFetch] 
                                                                   options:0 error:&error];
            [self parseRss:doc.rootElement entries:[[NSMutableArray alloc] init]];
            
            [tempView removeFromSuperview];
            self.navigationItem.rightBarButtonItem = self.refresh;
            
            [reachability stopNotifier];
        });
    };
    
    reach.unreachableBlock = ^(Reachability *reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"Connection Failed"
                                  message: @"Unable to connect to the Arseblog News site to download the latest news items."
                                  delegate: nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
            
            [reachability stopNotifier];
        });
    };
    
    [reach startNotifier];
    
}

- (void)parseRss:(GDataXMLElement *)rootElement entries:(NSMutableArray *)entries {
    
    NSRegularExpression *removeImageFromDescription = [[NSRegularExpression alloc] initWithPattern:@"<img (.+) />" options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSArray *channels = [rootElement elementsForName:@"channel"];
    for (GDataXMLElement *channel in channels) {                    
        
        NSArray *items = [channel elementsForName:@"item"];
        for (GDataXMLElement *item in items) {
            
            NSString *articleGuid = [[item valueForChild:@"guid"] stringByReplacingOccurrencesOfString:@"http://news.arseblog.com/?p=" withString:@""];
            NSString *articleTitle = [item valueForChild:@"title"];
            NSString *articleUrl = [item valueForChild:@"feedburner:origLink"];            
            NSString *articleDateString = [item valueForChild:@"pubDate"];
            NSDate *articleDate = [NSDate dateFromInternetDateTimeString:articleDateString formatHint:DateFormatHintRFC822];
            NSString *articleDescription = [removeImageFromDescription stringByReplacingMatchesInString:[item valueForChild:@"description"] options:0 range:NSMakeRange(0, [[item valueForChild:@"description"] length]) withTemplate:@""];
            
            NSRange rangeOfFirstIFrame = [[item valueForChild:@"content:encoded"] rangeOfString:@"<iframe"];
            NSString *articleContent = (rangeOfFirstIFrame.location != NSNotFound) ? [[item valueForChild:@"content:encoded"] substringToIndex:rangeOfFirstIFrame.location] : [item valueForChild:@"content:encoded"];
            
            NSString *articleAuthor = [item valueForChild:@"dc:creator"];
            
            articleContent = [NSString stringWithFormat:@"<html><head><style type=\"text/css\">body {font-family: helvetica; font-size: 14px;}</style></head><body><span style=\"font-size: 16px; font-weight:bold;\">%@</span><br /><span style=\"font-size:12px; color:#999999\">%@ | %@</span><br />%@</body></html>", articleTitle, [articleDate descriptionWithLocale:nil], articleAuthor, articleContent];
            
            [NewsEntry newsEntryFromGuid:articleGuid withTitle:articleTitle withEntryDate:articleDate withEntryDescription:articleDescription withEntryContent:articleContent withLink:articleUrl withAuthor:articleAuthor inManagedContext:self.newsEntryDatabase.managedObjectContext];
        }      
    }
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"NewsEntry"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"entryDate" ascending:NO]];
    NSError *error = nil;
    NSArray *matches = [self.newsEntryDatabase.managedObjectContext executeFetchRequest:request error:&error];
    
    int articleCount = 1;
    for (NewsEntry *n in matches)
    {
        if (articleCount > MAX_ARTICLE_COUNT)
        {
            [self.newsEntryDatabase.managedObjectContext deleteObject:n];
        }
        articleCount++;
    }
    
    [self.newsEntryDatabase saveToURL:self.newsEntryDatabase.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
        [self.view setNeedsDisplay];
    }];
    [self.newsEntryDatabase.managedObjectContext save:nil];
}

- (void)parseFeed:(GDataXMLElement *)rootElement entries:(NSMutableArray *)entries {    
    if ([rootElement.name compare:@"rss"] == NSOrderedSame) {
        [self parseRss:rootElement entries:entries];
    }   
}

- (void)useDocument
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.newsEntryDatabase.fileURL path]])
    {
        [self.newsEntryDatabase saveToURL:self.newsEntryDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler: ^(BOOL success){
            [self setupFetchedResultsController];
        }];
    }
    else if (self.newsEntryDatabase.documentState == UIDocumentStateClosed)
    {
        [self.newsEntryDatabase openWithCompletionHandler:^(BOOL success){
            [self setupFetchedResultsController];
        }];
    }
    else if (self.newsEntryDatabase.documentState == UIDocumentStateNormal)
    {
        [self.newsEntryDatabase openWithCompletionHandler:^(BOOL success){
            [self setupFetchedResultsController];
        }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *path = [self.tableView indexPathForCell:sender];
    NewsEntry *entry = [self.fetchedResultsController objectAtIndexPath:path];
    
    if ([segue.destinationViewController respondsToSelector:@selector(setNewsEntry:)])
    {
        [segue.destinationViewController performSelector:@selector(setNewsEntry:) withObject:entry];
    }
}

@end
