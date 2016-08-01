//
//  AppDelegate.m
//  DenverRail
//
// 2008 - 2013 Tack Mobile.
//

#import "AppDelegate.h"
#import "TimetableSearchUtility.h"
#import "WhistleBlowerController.h"
#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVFoundation.h>

static NSString *const kPlaySoundsKey = @"playSoundsKey";
static NSString *const kPreferencesSetKey = @"prefsSet";
static NSString *const kPreferencesSetValue = @"prefsSet";

@interface AppDelegate()

/**
 WhistleBlower easter egg
 */
@property (strong, nonatomic) WhistleBlowerController *whistleBlower;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    [self initializeAudioPreferences];
    [self initializeAudio];
    [self initStations];
	
    return YES;
}

// Checks sound when application comes from foreground 
- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self initializeAudioPreferences];
}

/**
 Initializes the stations with their image name, database name, coordinates, and
 booleans if they are one direction only and if they are east and west instead of north and south
 */
- (void)initStations {
	self.stations = [NSMutableArray new];

    [self.stations addObject:[[Station alloc] initWithColumnName:@"10th & Osage Station"
                                                        latitude:39.7318 longitude:-105.0056 southOnly:NO northOnly:NO eastWest:NO]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"16th & California Station"
                                                        latitude:39.744919 longitude:-104.992428 southOnly:NO northOnly:YES eastWest:NO]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"16th & Stout Station"
                                                        latitude:39.746166 longitude:-104.992759 southOnly:YES northOnly:NO eastWest:NO]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"18th & California Station"
                                                        latitude:39.746767 longitude:-104.990028 southOnly:NO northOnly:YES eastWest:NO]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"18th & Stout Station"
                                                        latitude:39.748018 longitude:-104.990404 southOnly:YES northOnly:NO eastWest:NO]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"20th & Welton Station"
                                                        latitude:39.747926 longitude:-104.986889 southOnly:NO northOnly:NO eastWest:NO]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"25th & Welton Station"
                                                        latitude:39.753392 longitude:-104.979764 southOnly:NO northOnly:NO eastWest:NO]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"27th & Welton Station"
                                                       latitude:39.755233 longitude:-104.977370 southOnly:NO northOnly:NO eastWest:NO]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"30th & Downing Station"
                                                         latitude:39.758800 longitude:-104.973572 southOnly:NO northOnly:NO eastWest:NO]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"38th & Blake Station"
                                                        latitude:39.770923 longitude:-104.973076 southOnly:NO northOnly:NO eastWest:YES]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"40th & Colorado Station"
                                                        latitude:39.775912 longitude:-104.942201 southOnly:NO northOnly:NO eastWest:YES]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"40th Ave & Airport Blvd - Gateway Park S"
                                                        latitude:39.769905 longitude:-104.787682 southOnly:NO northOnly:NO eastWest:YES]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"61st & Pena Station"
                                                        latitude:39.806895 longitude:-104.783999 southOnly:NO northOnly:NO eastWest:YES]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"Alameda Station"
                                                         latitude:39.7084 longitude:-104.9929 southOnly:NO northOnly:NO eastWest:NO]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"Arapahoe at Village Center Station"
                                                         latitude:39.6002 longitude:-104.8884 southOnly:NO northOnly:NO eastWest:NO]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"Auraria West Station"
                                                         latitude:39.741300 longitude:-105.008970 southOnly:NO northOnly:NO eastWest:NO]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"Belleview Station"
                                                         latitude:39.6275 longitude:-104.9043 southOnly:NO northOnly:NO eastWest:NO]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"Central Park Station"
                                                        latitude:39.770646 longitude:-104.891652 southOnly:NO northOnly:NO eastWest:YES]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"Colfax at Auraria Station"
                                                         latitude:39.7403 longitude:-105.0019 southOnly:NO northOnly:NO eastWest:NO]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"Colorado Station"
                                                         latitude:39.6796 longitude:-104.9377 southOnly:NO northOnly:NO eastWest:NO]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"County Line Station"
                                                         latitude:39.5617 longitude:-104.8722 southOnly:NO northOnly:NO eastWest:NO]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"Dayton Station"
                                                         latitude:39.6430 longitude:-104.8779 southOnly:NO northOnly:NO eastWest:NO]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"Decatur / Federal Station"
                                                        latitude:39.735687 longitude:-105.024452 southOnly:NO northOnly:NO eastWest:YES]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"Denver Airport Station"
                                                        latitude:39.847468 longitude:-104.673853 southOnly:NO northOnly:NO eastWest:YES]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"Dry Creek Station"
                                                         latitude:39.5788 longitude:-104.8765 southOnly:NO northOnly:NO eastWest:NO]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"Englewood Station"
                                                        latitude:39.6556 longitude:-104.9999 southOnly:NO northOnly:NO eastWest:NO]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"Evans Station"
                                                        latitude:39.6776 longitude:-104.9928 southOnly:NO northOnly:NO eastWest:NO]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"Federal Center Station"
                                                        latitude:39.711852 longitude:-105.125347 southOnly:NO northOnly:NO eastWest:YES]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"Garrison Station"
                                                        latitude:39.736608 longitude:-105.099811 southOnly:NO northOnly:NO eastWest:YES]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"I-25 & Broadway Station"
                                                        latitude:39.701523 longitude:-104.990158 southOnly:NO northOnly:NO eastWest:NO]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"Jeffco Government Center Station"
                                                        latitude:39.726640 longitude:-105.201728 southOnly:NO northOnly:NO eastWest:YES]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"Knox Station"
                                                        latitude:39.735687 longitude:-105.033303 southOnly:NO northOnly:NO eastWest:YES]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"Lamar Station"
                                                        latitude:39.736683 longitude:-105.066872 southOnly:NO northOnly:NO eastWest:YES]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"Lincoln Station"
                                                        latitude:39.5459 longitude:-104.8696 southOnly:NO northOnly:NO eastWest:NO]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"Littleton / Downtown Station"
                                                        latitude:39.6119 longitude:-105.0149 southOnly:NO northOnly:NO eastWest:NO]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"Littleton / Mineral Ave Station"
                                                        latitude:39.5801 longitude:-105.0250 southOnly:NO northOnly:NO eastWest:NO]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"Louisiana & Pearl Station"
                                                        latitude:39.6928 longitude:-104.9782 southOnly:NO northOnly:NO eastWest:NO]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"Nine Mile Station"
                                                        latitude:39.6575 longitude:-104.8450 southOnly:NO northOnly:NO eastWest:NO]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"Oak Station"
                                                        latitude:39.737400 longitude:-105.120463 southOnly:NO northOnly:NO eastWest:YES]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"Orchard Station"
                                                        latitude:39.6134 longitude:-104.8961 southOnly:NO northOnly:NO eastWest:NO]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"Oxford - City of Sheridan Station"
                                                        latitude:39.6429 longitude:-105.0048 southOnly:NO northOnly:NO eastWest:NO]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"Peoria Station"
                                                        latitude:39.767553 longitude:-104.850501 southOnly:NO northOnly:NO eastWest:YES]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"Pepsi Center / Elitch Gardens Station"
                                                        latitude:39.7486 longitude:-105.0096 southOnly:NO northOnly:NO eastWest:NO]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"Perry Station"
                                                        latitude:39.734790 longitude:-105.040409 southOnly:NO northOnly:NO eastWest:YES]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"Red Rocks Community College Station"
                                                        latitude:39.725078 longitude:-105.152812 southOnly:NO northOnly:NO eastWest:YES]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"Sheridan Station"
                                                        latitude:39.735147 longitude:-105.053616 southOnly:NO northOnly:NO eastWest:YES]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"Southmoor Station"
                                                        latitude:39.6485 longitude:-104.91628 southOnly:NO northOnly:NO eastWest:NO]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"Sports Authority Field at Mile High Stat"
                                                        latitude:39.7434 longitude:-105.0131 southOnly:NO northOnly:NO eastWest:NO]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"Theatre District/Convention Ctr Station"
                                                        latitude:39.7437 longitude:-104.9963 southOnly:NO northOnly:NO eastWest:NO]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"Union Station"
                                                        latitude:39.755403 longitude:-105.002900 southOnly:NO northOnly:NO eastWest:NO]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"University of Denver Station"
                                                        latitude:39.6852 longitude:-104.9648 southOnly:NO northOnly:NO eastWest:NO]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"Wadsworth Station"
                                                        latitude:39.736664 longitude:-105.099811 southOnly:NO northOnly:NO eastWest:YES]];
    [self.stations addObject:[[Station alloc] initWithColumnName:@"Yale Station"
                                                        latitude:39.6686 longitude:-104.927 southOnly:NO northOnly:NO eastWest:NO]];
}

#pragma mark - Audio -

// Initializes the audio for the first time
- (void)initializeAudio {
    [AVAudioSession sharedInstance];
    self.whistleBlower = [[WhistleBlowerController alloc] init];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    self.whistleBlower.isOn = NO;
}

- (void)initializeAudioPreferences {
        NSString *pathStr = [[NSBundle mainBundle] bundlePath];
		NSString *settingsBundlePath = [pathStr stringByAppendingPathComponent:@"Settings.bundle"];
		NSString *finalPath = [settingsBundlePath stringByAppendingPathComponent:@"Root.plist"];
        
		NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfFile:finalPath];
		NSArray *prefSpecifierArray = [settingsDict objectForKey:@"PreferenceSpecifiers"];
    
        NSNumber *playSoundDefault;
        
		NSDictionary *prefItem;
		for (prefItem in prefSpecifierArray) {
           
			NSString *keyValueStr = [prefItem objectForKey:@"Key"];
			id defaultValue = [prefItem objectForKey:@"DefaultValue"];
			if ([keyValueStr isEqualToString:kPlaySoundsKey]) {
                playSoundDefault = defaultValue;
			}
		}
        
		NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:playSoundDefault, kPlaySoundsKey, nil];
      
		[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
		[[NSUserDefaults standardUserDefaults] synchronize];

        [[NSUserDefaults standardUserDefaults] setValue:kPreferencesSetKey forKey:kPreferencesSetKey];

        self.playSounds = [[NSUserDefaults standardUserDefaults] boolForKey:kPlaySoundsKey];
}

@end
