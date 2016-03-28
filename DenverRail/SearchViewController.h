//
//  SearchViewController.h
//  DenverRail
//
// 2008 - 2013 Tack Mobile.
//

#import <UIKit/UIKit.h>
#import "Station.h"

@protocol SearchStationDelegate <NSObject>

- (void)searchStationSelected:(Station *)stationName;
- (void)searchCancelTapped;

@end

@interface SearchViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong) NSObject <SearchStationDelegate> *delegate;
- (void)showKeyboard;

@end
