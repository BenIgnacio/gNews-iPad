//
//  MasterViewController.m
//  gNews-iPad
//
//  Created by Ben on 2/13/13.
//  Copyright (c) 2013 com.Beni. All rights reserved.
//


#import "MasterViewController.h"
#import "DetailViewController.h"
#import "story.h"
#import "SectionPickerController.h"

//Constants for web services URL
#define bgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1

#define gNews @"https://ajax.googleapis.com/ajax/services/search/news?v=1.0&rsz=8&ned=US&topic="

#define gNewsTech [NSURL URLWithString: @"https://ajax.googleapis.com/ajax/services/search/news?v=1.0&topic=t&userip=INSERT-USER-IP"]
#define gNewsTechNoIP [NSURL URLWithString: @"https://ajax.googleapis.com/ajax/services/search/news?v=1.0&topic=t&rsz=8&ned=US"]
#define gNewsTopStories [NSURL URLWithString: @"https://ajax.googleapis.com/ajax/services/search/news?v=1.0&topic=h&rsz=8&ned=US"]


//Categories for JSON parsing
@interface NSDictionary(JSONCategories)
+(NSDictionary*)dictionaryWithContentsOfJSONURLString:(NSString*)urlAddress;
-(NSData*)toJSON;
@end

@implementation NSDictionary(JSONCategories)
+(NSDictionary*)dictionaryWithContentsOfJSONURLString:(NSString*)urlAddress
{
    NSData* data = [NSData dataWithContentsOfURL: [NSURL URLWithString: urlAddress] ];
    __autoreleasing NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}

-(NSData*)toJSON
{
    NSError* error = nil;
    id result = [NSJSONSerialization dataWithJSONObject:self options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}
@end

@interface MasterViewController () {
    NSMutableArray *_objects;
    NSMutableArray *storyArray;

}
@end


@implementation MasterViewController

@synthesize sectionPicker = _sectionPicker;
@synthesize sectionPickerPopover = _sectionPickerPopover;
@synthesize sectionChar;

- (void)awakeFromNib
{
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    [super awakeFromNib];
}


/***********************************************
 
 viewDidLoad ()
 
 Call Google News web services api and parse the returned JSON object in a background thread.
 **********************************************/
 
- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view, typically from a nib.
    
    /*Call Google news web services and parse the JSON in background thread
    dispatch_async(bgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: gNewsTechNoIP];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
    */
    
    //Call Google news web services and parse the JSON in main thread instead because tableView methods are getting called before background thread finishes.
    
    //Load with top stories.
    NSData* data = [NSData dataWithContentsOfURL: gNewsTopStories];

    //Check for error
    if (data == nil) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"News"
                              message: @"Network error: please check your internet connection."
                              delegate: nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil];
        [alert show];
    } else {
        [self performSelector:@selector(fetchedData:) withObject:data];
        self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];

        //Set 1st story in webView
        self.detailViewController.detailItem = [storyArray objectAtIndex:0];
    }
}


/******************************************
 
    fetchedData()
 
    Parse the JSON object
 *****************************************/

- (void)fetchedData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData
                                                         options:kNilOptions
                                                           error:&error];
    //Dictionary - top most level.
    NSDictionary *rData = [json objectForKey:@"responseData"];
    
    //rData is array of dictionaries.
    NSArray *results = [rData objectForKey:@"results"];

    //Loop to process each story. Create story item and add to storyArray.
    if (!storyArray) {
        storyArray = [[NSMutableArray alloc] init];
    }
    
    //Clear content of array for new data
    [storyArray removeAllObjects];
    
    for (int i = 0; i < results.count; i++) {
        NSDictionary *newsItem = [results objectAtIndex:i];
    
        //Get image URL
        NSURL *imageUrl = [NSURL URLWithString:[[newsItem objectForKey:@"image"] objectForKey:@"tbUrl"]];
        
        //Get related stories
        NSArray *relatedStories = [newsItem objectForKey:@"relatedStories"];
    
        //If there are no related stories get title and story URL from newsItem.
        NSString *title;
        NSURL *storyUrl;
        if (relatedStories == nil) {
            title = [newsItem objectForKey:@"title"];
            storyUrl = [NSURL URLWithString:[newsItem objectForKey:@"signedRedirectUrl"]];
        }
        else {
            //Get first story, its title and URL.
            NSDictionary *aStory = [relatedStories objectAtIndex:0];
            title = [aStory objectForKey:@"title"];
            storyUrl = [NSURL URLWithString:[aStory objectForKey:@"signedRedirectUrl"]];
        }
 
        //replace "<b>...</b>",  "&#39;" and "" in title string
        title = [title stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"];
        title = [title stringByReplacingOccurrencesOfString:@"<b>...</b>" withString:@""];
        title = [title stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];

        //Create a story object
        story *storyBuff = [[story alloc] initWithData:title imageURL:imageUrl storyURL:storyUrl];
        
        //Add to storyArray
        [storyArray addObject:storyBuff];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}
*/
 
#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return storyArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    cell.textLabel.text = [[storyArray objectAtIndex:indexPath.row] title];
    
    /*
    //Load images in background thread if perf is slow.
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    dispatch_async(concurrentQueue, ^{
        NSData *image = [[NSData alloc] initWithContentsOfURL:[[storyArray objectAtIndex:indexPath.row] imageURL]];
        
        //this will set the image when loading is finished
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.imageView.image = [UIImage imageWithData:image];
        });
    });
    */
    
    //Use default image if news cluster doesn't come with image.
    if ([[storyArray objectAtIndex:indexPath.row] imageURL] == nil)
        cell.imageView.image = [UIImage imageNamed:@"Folded-Newspaper.png"];
    else {
        NSData *image = [[NSData alloc] initWithContentsOfURL:[[storyArray objectAtIndex:indexPath.row] imageURL]];
        cell.imageView.image = [UIImage imageWithData:image];
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

/*
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}
*/
/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.detailViewController.detailItem = [storyArray objectAtIndex:indexPath.row];
}



- (IBAction)setSectionButtonTapped:(id)sender {

    //If open already, close it
    if (self.sectionPickerPopover.isPopoverVisible) {
        [self.sectionPickerPopover dismissPopoverAnimated:YES];
        return;
    }
    
    if (_sectionPicker == nil) {
        self.sectionPicker = [[SectionPickerController alloc] initWithStyle:UITableViewStylePlain];
        _sectionPicker.delegate = self;
        self.sectionPickerPopover = [[UIPopoverController alloc] initWithContentViewController:_sectionPicker];
    }

    [self.sectionPickerPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}


- (void)sectionSelected:(NSString *)section {
    //Set nav bar label to section
    
    //Set query char
    if ([section compare:sectionHeadlines] == NSOrderedSame) {
        sectionChar = @"h";
    } else if ([section compare:sectionWorld] == NSOrderedSame) {
        sectionChar = @"w";
    } else if ([section compare:sectionBusiness] == NSOrderedSame){
        sectionChar = @"b";
    } else if ([section compare:sectionNation] == NSOrderedSame){
        sectionChar = @"n";
    } else if ([section compare:sectionTech] == NSOrderedSame){
        sectionChar = @"t";
    } else if ([section compare:sectionPolitics] == NSOrderedSame){
        sectionChar = @"p";
    } else if ([section compare:sectionEntertainment] == NSOrderedSame){
        sectionChar = @"e";
    } else if ([section compare:sectionSports] == NSOrderedSame){
        sectionChar = @"s";
    } else if ([section compare:sectionHealth] == NSOrderedSame){
        sectionChar = @"m";
    }
    
    [self.sectionPickerPopover dismissPopoverAnimated:YES];

    //Change navigation bar text
    self.navigationController.navigationBar.topItem.title = section;
    
    //Get new headlines and show in tableview
    NSURL *gNewsURL = [NSURL URLWithString:[gNews stringByAppendingString:sectionChar]];
    NSData* data = [NSData dataWithContentsOfURL: gNewsURL];
    
    //Check for error
    if (data == nil) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"News"
                              message: @"Network error: please check your internet connection."
                              delegate: nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil];
        [alert show];
    } else {
        [self performSelector:@selector(fetchedData:) withObject:data];
        [self.tableView reloadData];
    }
}

@end
