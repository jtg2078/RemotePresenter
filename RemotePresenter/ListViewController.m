//
//  ListViewController.m
//  RemotePresenter
//
//  Created by jason on 10/23/12.
//  Copyright (c) 2012 jason. All rights reserved.
//

#import "ListViewController.h"

@interface ListViewController ()

@end

@implementation ListViewController

@synthesize qvc;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    movieManager = [MovieManager sharedInstance];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	//BOOL isLandscapeRight = (UIInterfaceOrientationLandscapeRight == interfaceOrientation);
    //return isLandscapeRight;
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    int rows = movieManager.moviesArray.count;
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MovieCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.minimumFontSize = 10.0f;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSString *name = [movieManager.namesArray objectAtIndex:indexPath.row];
    NSString *str = [NSString stringWithFormat:@"%d. %@", indexPath.row + 1, name];
    cell.textLabel.text = str;
}

#pragma mark - Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *currentSelected = tableView.indexPathForSelectedRow;
    
    if(currentSelected == nil)
        return indexPath;
    else if(currentSelected.row == indexPath.row)
        return nil;
    else
        return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.qvc playMovie:[movieManager.moviesArray objectAtIndex:indexPath.row]
                movieId:indexPath.row];
}

@end
