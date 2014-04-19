//
//  SearchViewController.h
//  DenverRail
//
// 2008 - 2013 Tack Mobile.
//

#import <UIKit/UIKit.h>
#import "Station.h"

@protocol SearchStationDelegate <NSObject>
@required
- (void)searchStationSelected:(Station *)stationName;
- (void)searchCancelTapped;
@end

@interface SearchViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak) IBOutlet UITextField *searchBoxTextField;
@property (strong) NSObject <SearchStationDelegate> *delegate;
@property (weak) IBOutlet UITableView *tableView;
@property (weak) NSArray *allStations;
@property (strong) NSMutableArray *matchingStations;

- (IBAction)doneEditing:(UITextField *)_textField;
- (IBAction)textFieldChanged:(id)sender;
- (IBAction)cancelTapped:(id)sender;
- (void)showKeyboard;

@end
