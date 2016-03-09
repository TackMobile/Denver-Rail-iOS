//
//  AppDelegate.m
//  DenverRail
//
// 2008 - 2013 Tack Mobile.
//

#import "AppDelegate.h"
#import "BaseViewController.h"
#import "TimetableSearchUtility.h"
#import "WhistleBlowerController.h"
#import <AudioToolbox/AudioServices.h>

NSString static *kPlaySoundsKey = @"playSoundsKey";
NSString static *kPreferencesSetKey = @"prefsSet";
NSString static *kPreferencesSetValue = @"prefsSet";

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize stations;
@synthesize whistleBlower;
@synthesize playSounds;

// Starts the application 
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
    [self initializePreferences];
    [self initializeAudio];
    [self initStations];
    
//    [TestFlight takeOff:@"8c164a2e084013eae880e49cf6a4e005_NTU1MTAyMDEyLTAzLTIyIDE4OjE2OjE5LjAzNzQ2OA"];
	
    return YES;
}

// Checks sound when application comes from foreground 
- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self initializePreferences];
    NSLog(@" Play sounds is %@", (self.playSounds ? @"ON" : @"OFF")); 
    [self configureAudioSession];
}

// Initializes the audio for the first time
- (void)initializeAudio {
//    AudioSessionInitialize(NULL, NULL, NULL, NULL);
	[AVAudioSession sharedInstance];
    self.whistleBlower = [[WhistleBlowerController alloc] init];
    [self configureAudioSession];
//    AudioSessionSetActive(YES);
	NSError *error = [[NSError alloc] init];
	[[AVAudioSession sharedInstance] setActive:YES error:&error];
}

// Configures the audio session
- (void) configureAudioSession {
//    UInt32 otherAudioIsPlaying;
//    UInt32 propertySize = sizeof(otherAudioIsPlaying);
//	  AudioSessionGetProperty(kAudioSessionProperty_OtherAudioIsPlaying, &propertySize, &otherAudioIsPlaying);
	
	BOOL isPlayingWithOthers = [[AVAudioSession sharedInstance] isOtherAudioPlaying];
	NSError *error = [[NSError alloc] init];
    
    if (isPlayingWithOthers && self.playSounds) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:&error];
    } else if (self.playSounds) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:&error];
    }
    
    self.whistleBlower.on = NO;
    
//	if (otherAudioIsPlaying && self.playSounds) {
    //if (isPlayingWithOthers && self.playSounds) {
		
        // Let our sounds blend with theirs in a beautiful melody.
//        UInt32 category = kAudioSessionCategory_AmbientSound;
//        AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
		
		//[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:&error];
        
        //self.whistleBlower.on = NO;

    //} else if(self.playSounds) {
        
        // Enable playing and recording in the audio session so the Train whistle sillyness can take place.
//        UInt32 category = kAudioSessionCategory_PlayAndRecord;
//        AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
		//[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&error];
		
//        UInt32 allowMixing = true; 
//        AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(allowMixing), &allowMixing);
//		[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
		
//        UInt32 defaultToSpeaker = kAudioSessionProperty_OverrideCategoryDefaultToSpeaker;
//        AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(defaultToSpeaker), &defaultToSpeaker);
		
		//[[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
        
        //self.whistleBlower.on = YES;
    //} else {
        //self.whistleBlower.on = NO;
    //}
}

// Tests the data
- (void)test {
    NSArray *result = [TimetableSearchUtility getTimetableWithStation:[self.stations objectAtIndex:0] directionIsNorth:NO];
    
    if(result)
        NSLog(@"result count: %i", [result count]);
    else
        NSLog(@"no results (returned nil)");
}

// Initializes the stations with their image name, database name, coordinates, and
// booleans if they are one direction only and if they are east and west instead of north and south
- (void)initStations {
	self.stations = [NSMutableArray new];
    
	[self.stations addObject:[[Station alloc] initWithImageName:@"10th-osage" columnName:@"10th & Osage Station"
                                                       latitude:39.7318 logitude:-105.0056 southOnly:NO northOnly:NO eastWest:NO]];
     [self.stations addObject:[[Station alloc] initWithImageName:@"16th-california" columnName:@"16th & California Station"
                                                        latitude:39.744919 logitude:-104.992428 southOnly:NO northOnly:YES eastWest:NO]];
     [self.stations addObject:[[Station alloc] initWithImageName:@"16th-stout" columnName:@"16th & Stout Station"
                                                        latitude:39.746166 logitude:-104.992759 southOnly:YES northOnly:NO eastWest:NO]];
     [self.stations addObject:[[Station alloc] initWithImageName:@"18th-california" columnName:@"18th & California Station"
                                                        latitude:39.746767 logitude:-104.990028 southOnly:NO northOnly:YES eastWest:NO]];
     [self.stations addObject:[[Station alloc] initWithImageName:@"18th-stout" columnName:@"18th & Stout Station"
                                                        latitude:39.748018 logitude:-104.990404 southOnly:YES northOnly:NO eastWest:NO]];
     [self.stations addObject:[[Station alloc] initWithImageName:@"20th-welton" columnName:@"20th & Welton Station"
                                                        latitude:39.747926 logitude:-104.986889 southOnly:NO northOnly:NO eastWest:NO]];
     [self.stations addObject:[[Station alloc] initWithImageName:@"25th-welton" columnName:@"25th & Welton Station"
                                                        latitude:39.753392 logitude:-104.979764 southOnly:NO northOnly:NO eastWest:NO]];
     [self.stations addObject:[[Station alloc] initWithImageName:@"27th-welton" columnName:@"27th & Welton Station"
                                                       latitude:39.755233 logitude:-104.977370 southOnly:NO northOnly:NO eastWest:NO]];
      [self.stations addObject:[[Station alloc] initWithImageName:@"30th-downing" columnName:@"30th & Downing Station"
                                                         latitude:39.758800 logitude:-104.973572 southOnly:NO northOnly:NO eastWest:NO]];
      [self.stations addObject:[[Station alloc] initWithImageName:@"alameda" columnName:@"Alameda Station"
                                                         latitude:39.7084 logitude:-104.9929 southOnly:NO northOnly:NO eastWest:NO]];
      [self.stations addObject:[[Station alloc] initWithImageName:@"arapahoe" columnName:@"Arapahoe at Village Center Station"
                                                         latitude:39.6002 logitude:-104.8884 southOnly:NO northOnly:NO eastWest:NO]];
      [self.stations addObject:[[Station alloc] initWithImageName:@"auraria-west" columnName:@"Auraria West Station"
                                                         latitude:39.741300 logitude:-105.008970 southOnly:NO northOnly:NO eastWest:NO]];
      [self.stations addObject:[[Station alloc] initWithImageName:@"belleview" columnName:@"Belleview Station"
                                                         latitude:39.6275 logitude:-104.9043 southOnly:NO northOnly:NO eastWest:NO]];
      [self.stations addObject:[[Station alloc] initWithImageName:@"colfax-auraria" columnName:@"Colfax at Auraria Station"
                                                         latitude:39.7403 logitude:-105.0019 southOnly:NO northOnly:NO eastWest:NO]];
      [self.stations addObject:[[Station alloc] initWithImageName:@"colorado" columnName:@"Colorado Station"
                                                         latitude:39.6796 logitude:-104.9377 southOnly:NO northOnly:NO eastWest:NO]];
      [self.stations addObject:[[Station alloc] initWithImageName:@"county-line" columnName:@"County Line Station"
                                                         latitude:39.5617 logitude:-104.8722 southOnly:NO northOnly:NO eastWest:NO]];
      [self.stations addObject:[[Station alloc] initWithImageName:@"dayton" columnName:@"Dayton Station"
                                                         latitude:39.6430 logitude:-104.8779 southOnly:NO northOnly:NO eastWest:NO]];
      [self.stations addObject:[[Station alloc] initWithImageName:@"decatur-federal" columnName:@"Decatur / Federal Station"
                                                        latitude:39.735687 logitude:-105.024452 southOnly:NO northOnly:NO eastWest:YES]];
      [self.stations addObject:[[Station alloc] initWithImageName:@"dry-creek" columnName:@"Dry Creek Station"
                                                         latitude:39.5788 logitude:-104.8765 southOnly:NO northOnly:NO eastWest:NO]];
      [self.stations addObject:[[Station alloc] initWithImageName:@"englewood" columnName:@"Englewood Station"
                                                         latitude:39.6556 logitude:-104.9999 southOnly:NO northOnly:NO eastWest:NO]];
      [self.stations addObject:[[Station alloc] initWithImageName:@"evans" columnName:@"Evans Station"
                                                         latitude:39.6776 logitude:-104.9928 southOnly:NO northOnly:NO eastWest:NO]];
      [self.stations addObject:[[Station alloc] initWithImageName:@"federal-center" columnName:@"Federal Center Station"
                                                         latitude:39.711852 logitude:-105.125347 southOnly:NO northOnly:NO eastWest:YES]];
      [self.stations addObject:[[Station alloc] initWithImageName:@"garrison" columnName:@"Garrison Station"
                                                         latitude:39.736608 logitude:-105.099811 southOnly:NO northOnly:NO eastWest:YES]];
      [self.stations addObject:[[Station alloc] initWithImageName:@"i25-broadway" columnName:@"I-25 & Broadway Station"
                                                         latitude:39.701523 logitude:-104.990158 southOnly:NO northOnly:NO eastWest:NO]];
      [self.stations addObject:[[Station alloc] initWithImageName:@"jeffco-golden" columnName:@"Jeffco Government Center Station"
                                                         latitude:39.726640 logitude:-105.201728 southOnly:NO northOnly:NO eastWest:YES]];
      [self.stations addObject:[[Station alloc] initWithImageName:@"knox" columnName:@"Knox Station"
                                                         latitude:39.735687 logitude:-105.033303 southOnly:NO northOnly:NO eastWest:YES]];
      [self.stations addObject:[[Station alloc] initWithImageName:@"lamar" columnName:@"Lamar Station"
                                                         latitude:39.736683 logitude:-105.066872 southOnly:NO northOnly:NO eastWest:YES]];
      [self.stations addObject:[[Station alloc] initWithImageName:@"lincoln" columnName:@"Lincoln Station"
                                                         latitude:39.5459 logitude:-104.8696 southOnly:NO northOnly:NO eastWest:NO]];
      [self.stations addObject:[[Station alloc] initWithImageName:@"littleton-downtown" columnName:@"Littleton / Downtown Station"
                                                         latitude:39.6119 logitude:-105.0149 southOnly:NO northOnly:NO eastWest:NO]];
      [self.stations addObject:[[Station alloc] initWithImageName:@"littleton-mineral" columnName:@"Littleton / Mineral Ave Station"
                                                         latitude:39.5801 logitude:-105.0250 southOnly:NO northOnly:NO eastWest:NO]];
      [self.stations addObject:[[Station alloc] initWithImageName:@"louisiana-pearl" columnName:@"Louisiana & Pearl Station"
                                                         latitude:39.6928 logitude:-104.9782 southOnly:NO northOnly:NO eastWest:NO]];
      [self.stations addObject:[[Station alloc] initWithImageName:@"nine-mile" columnName:@"Nine Mile Station"
                                                         latitude:39.6575 logitude:-104.8450 southOnly:NO northOnly:NO eastWest:NO]];
      [self.stations addObject:[[Station alloc] initWithImageName:@"oak" columnName:@"Oak Station"
                                                         latitude:39.737400 logitude:-105.120463 southOnly:NO northOnly:NO eastWest:YES]];
      [self.stations addObject:[[Station alloc] initWithImageName:@"orchard" columnName:@"Orchard Station"
                                                         latitude:39.6134 logitude:-104.8961 southOnly:NO northOnly:NO eastWest:NO]];
      [self.stations addObject:[[Station alloc] initWithImageName:@"oxford-sheridan" columnName:@"Oxford - City of Sheridan Station"
                                                         latitude:39.6429 logitude:-105.0048 southOnly:NO northOnly:NO eastWest:NO]];
      [self.stations addObject:[[Station alloc] initWithImageName:@"pepsi-center" columnName:@"Pepsi Center / Elitch Gardens Station"
                                                         latitude:39.7486 logitude:-105.0096 southOnly:NO northOnly:NO eastWest:NO]];
      [self.stations addObject:[[Station alloc] initWithImageName:@"perry" columnName:@"Perry Station"
                                                         latitude:39.734790 logitude:-105.040409 southOnly:NO northOnly:NO eastWest:YES]];
      [self.stations addObject:[[Station alloc] initWithImageName:@"red-rocks-college" columnName:@"Red Rocks Community College Station"
                                                         latitude:39.725078 logitude:-105.152812 southOnly:NO northOnly:NO eastWest:YES]];
      [self.stations addObject:[[Station alloc] initWithImageName:@"sheridan" columnName:@"Sheridan Station"
                                                         latitude:39.735147 logitude:-105.053616 southOnly:NO northOnly:NO eastWest:YES]];
      [self.stations addObject:[[Station alloc] initWithImageName:@"hampden-southmoor" columnName:@"Southmoor Station"
                                                       latitude:39.6485 logitude:-104.91628 southOnly:NO northOnly:NO eastWest:NO]];
      [self.stations addObject:[[Station alloc] initWithImageName:@"mile-high" columnName:@"Sports Authority Field at Mile High Stat"
                                                       latitude:39.7434 logitude:-105.0131 southOnly:NO northOnly:NO eastWest:NO]];
      [self.stations addObject:[[Station alloc] initWithImageName:@"convention-center" columnName:@"Theatre District/Convention Ctr Station"
                                                       latitude:39.7437 logitude:-104.9963 southOnly:NO northOnly:NO eastWest:NO]];
      [self.stations addObject:[[Station alloc] initWithImageName:@"union-station" columnName:@"Union Station"
                                                         latitude:39.7526 logitude:-105.0008 southOnly:NO northOnly:NO eastWest:NO]];
      [self.stations addObject:[[Station alloc] initWithImageName:@"university"columnName:@"University of Denver Station"
                                                         latitude:39.6852 logitude:-104.9648 southOnly:NO northOnly:NO eastWest:NO]];
      [self.stations addObject:[[Station alloc] initWithImageName:@"lakewood-wadsworth" columnName:@"Wadsworth Station"
                                                         latitude:39.736664 logitude:-105.099811 southOnly:NO northOnly:NO eastWest:YES]];
      [self.stations addObject:[[Station alloc] initWithImageName:@"yale" columnName:@"Yale Station"
                                                         latitude:39.6686 logitude:-104.927 southOnly:NO northOnly:NO eastWest:NO]];
}

// Sets up the audio preferences
- (void) initializePreferences {
//    NSString *prefsInitializedString = [[NSUserDefaults standardUserDefaults] stringForKey:kPreferencesSetKey];
	
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
