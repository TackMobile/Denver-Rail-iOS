//
//  SearchViewController.m
//  DenverRail
//
//  2008 - 2013 Tack Mobile. 
//

#import "SearchViewController.h"
#import "AppDelegate.h"
#import "NSString+Common.h"

@interface SearchViewController ()

@end

@implementation SearchViewController
@synthesize searchBoxTextField, tableView;
@synthesize delegate;
@synthesize allStations, matchingStations;


// When the view is loaded
- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.allStations = ad.stations;
    self.matchingStations = [NSMutableArray new];
    [matchingStations addObjectsFromArray:allStations];
    
    // Notifications on keyboard events 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

// Show keyboard for search
- (void)showKeyboard {
    [self.searchBoxTextField becomeFirstResponder];
}

// When the cancel button is pressed
- (IBAction)cancelTapped:(id)sender {
    searchBoxTextField.text = @"";
    [searchBoxTextField resignFirstResponder];
    [self.delegate searchCancelTapped];
}

// When the user enters in text for search
- (IBAction)textFieldChanged:(id)sender {
    
    [matchingStations removeAllObjects];
    
    if ([searchBoxTextField.text isBlank])
        [matchingStations addObjectsFromArray:allStations];
    else

        // Find all matching stations
        for(Station *currentStation in allStations) {
            if ([[currentStation.columnName lowercaseString] contains:[searchBoxTextField.text lowercaseString]]) {
                    [matchingStations addObject:currentStation];
            }
        }
    
    // Station name Wadsworth - Lakewood is in database as only wadsworth. Last item in both arrays is that station
    if ([searchBoxTextField.text contains:@"l"]) {
        [matchingStations addObject:[allStations lastObject]];
    }
    
    [tableView reloadData];
}

// When the user is done searching
- (IBAction)doneEditing:(UITextField *)_textField {
    [searchBoxTextField resignFirstResponder];
}

// When the user selects a station from the table 
- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    [searchBoxTextField resignFirstResponder];
    
    [delegate searchStationSelected:[self.matchingStations objectAtIndex:indexPath.row]];
}

// Shows the list of matching stations
- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    Station *currentStation = [self.matchingStations objectAtIndex:indexPath.row];
    
    // Replace some of the database names with a proper format 
    cell.textLabel.text = [currentStation.columnName stringByReplacingOccurrencesOfString:@"Station" withString:@""];
    
    cell.textLabel.text = [cell.textLabel.text stringByReplacingOccurrencesOfString:@"Stn" withString:@""];
    
    // Show the Lakewood part for that station
    if ([cell.textLabel.text contains:@"Wadsworth"])
        cell.textLabel.text = @"Wadsworth - Lakewood";
    
    return cell;
}

// Returns the number of matching stations 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.matchingStations count];
}

// Keep portrait orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // Adjust tableview height for the keyboard
    CGRect tableRect = CGRectMake(0,
                                  CGRectGetMinY(self.tableView.frame),
                                  CGRectGetWidth(self.tableView.frame),
                                  CGRectGetHeight(self.tableView.frame) - kbSize.height);
    [self.tableView setFrame:tableRect];
    
}

// Called when the UIKeyboardDidHide notification is sent
- (void)keyboardWillHide:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    // Adjust tableview height for the keyboard
    CGRect tableRect = CGRectMake(0,
                                  CGRectGetMinY(self.tableView.frame),
                                  CGRectGetWidth(self.tableView.frame),
                                  CGRectGetHeight(self.tableView.frame) + kbSize.height);
    [self.tableView setFrame:tableRect];
    
}

// When the view is unloaded
-(void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
