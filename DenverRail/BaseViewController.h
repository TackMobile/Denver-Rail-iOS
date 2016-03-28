//
//  BaseViewController.h
//  DenverRail
//
// 2008 - 2013 Tack Mobile.
//

#import <UIKit/UIKit.h>
#import "SearchViewController.h"

// Main view controller and booleans for each state of the application
@interface BaseViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, SearchStationDelegate> {
    BOOL isAutoMode;
    BOOL isNorth;
    BOOL isMapMode;
    BOOL isSearchMode;
}

@end
