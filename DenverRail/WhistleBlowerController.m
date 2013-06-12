//
//  WhistleBlowerController.m
//  DenverRail
//
// 2008 - 2013 Tack Mobile.
//

#import "WhistleBlowerController.h"
#import <AudioToolbox/AudioServices.h>

@interface WhistleBlowerController (Private)
- (void) ensurePlayersInitialized;
- (void) startSampling;
- (void) stopSampling;
- (BOOL) isSampling;
- (void) tick;
- (void) advanceState;
- (void) resetState;
- (void) chooseCurrentWhistle;
- (void) orientationDidChange:(NSNotification *)notification;
@end

#define kTicksBeforeStateReset 50
#define kTicksToIngoreInput 40
#define kWhistleSampleRate 0.02
#define kWhistleSampleThreshold 0.66

// Mostly yoinked from https://github.com/dcgrigsby/MicBlow.git
@implementation WhistleBlowerController
@synthesize on, recorder, timer, shortWhistle, toot, mediumWhistle, loudLongWhistle, currentPlayer;

// Set up mic
- (void) setOn:(BOOL)b {
    on = b;
    if (on) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationDidChange:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];
        [self ensurePlayersInitialized];
        if (self.recorder == nil) {
            NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
            
            //TODO: Do these need to be this high?
            NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithFloat: 11025.0],                 AVSampleRateKey,
                                      [NSNumber numberWithInt: kAudioFormatAppleIMA4],     AVFormatIDKey,
                                      [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
                                      [NSNumber numberWithInt: AVAudioQualityLow],         AVEncoderAudioQualityKey,
                                      nil];
            self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:NULL];
            if (self.recorder) {
                [self.recorder prepareToRecord];
                self.recorder.meteringEnabled = YES;
            }
        }
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self stopSampling];		
    }
}

// Check the state of the device to see if it should sample for whistle
- (void) orientationDidChange:(NSNotification *)notification {
    UIDeviceOrientation currentOrientation = [UIDevice currentDevice].orientation;
    
    // If upside down and portrait then start sampling
    if (currentOrientation == UIDeviceOrientationPortraitUpsideDown) {
        [self startSampling];
        
    // If not then do not sample and stop if already sampling
    } else {
        [self stopSampling];
    }
}

// Start the sampling for the whistle
- (void) startSampling {
    if ([self isSampling]) {
        return;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kWhistleSampleRate target:self selector:@selector(tick:) userInfo:nil repeats:YES];
    [self.recorder record];
}

// Stop the sampling for the whistle
- (void) stopSampling {
    [self.timer invalidate];
    [self.recorder stop];
    self.timer = nil;
    lastSample = 0;
}

// Checks if the timer is sampling
- (BOOL) isSampling {
    return (self.timer != nil); 
}

// Timer for mic 
- (void) tick:(NSTimer *)timer {
    if (ticksSinceLastWhistle >= kTicksBeforeStateReset) {
        [self resetState];
        ticksSinceLastWhistle = 0;
    } else {
        ticksSinceLastWhistle++;
    }
    
    
    [self.recorder updateMeters];
    
	const double ALPHA = 0.05;
	double peakPowerForChannel = pow(10, (0.05 * [self.recorder peakPowerForChannel:0]));
	lastSample = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * lastSample;	
	
	if (lastSample > kWhistleSampleThreshold) {
        //NSLog(@"Last sample: %f", lastSample);
        if (state == WhistleBlowerStateNoWhistleYet || ticksSinceLastWhistle >= kTicksToIngoreInput) {
            [self putYourLipsTogetherAndBlow];
        }
    }
}

// Blow the whistle! 
- (void) putYourLipsTogetherAndBlow {
    if (self.on && !whistlePlaying) {
        [self advanceState];
        [self chooseCurrentWhistle];
        [self.currentPlayer play];
        whistlePlaying = YES;
        ticksSinceLastWhistle = 0;
    }
}

// Select the current whistle
- (void) chooseCurrentWhistle {
    int random = arc4random() % 2;
    
    // Smaller whistles
    if (state == WhistleBlowerStateOneWhistle) {
        NSLog(@"Smaller whistles");
        if (random == 0) {
            self.currentPlayer = self.toot;
        } else {
            self.currentPlayer = self.shortWhistle;
        }
        
    // Longer whistles 
    } else if (state == WhistleBlowerStateMultipleWhistles) {
        NSLog(@"Longer whistles");
        if (random == 0) {
            self.currentPlayer = self.loudLongWhistle;
        } else {
            self.currentPlayer = self.mediumWhistle;
        }
    }
}

// Change the state of the whistleblower
- (void) advanceState {
    if (state == WhistleBlowerStateNoWhistleYet) {
        state = WhistleBlowerStateOneWhistle;
    } else if (state == WhistleBlowerStateOneWhistle) {
        state = WhistleBlowerStateMultipleWhistles;
    }
}

// Resets the state of the whistle blower
- (void) resetState {
    state = WhistleBlowerStateNoWhistleYet;
}

// Ensure that the audio player is done playing
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    whistlePlaying = NO;
    self.currentPlayer = nil;
    lastSample = 0;
}

// Ensures that all sounds are initialized
- (void) ensurePlayersInitialized {
    NSURL *whistleURL = nil;
    if (self.toot == nil) {
        whistleURL = [[NSBundle mainBundle] URLForResource:@"toot" withExtension:@"caf"];
        self.toot = [[AVAudioPlayer alloc] initWithContentsOfURL:whistleURL error:NULL];
        self.toot.delegate = self;
        [self.toot prepareToPlay];
    }
    if (self.shortWhistle == nil) {
        whistleURL = [[NSBundle mainBundle] URLForResource:@"short_whistle" withExtension:@"caf"];
        self.shortWhistle = [[AVAudioPlayer alloc] initWithContentsOfURL:whistleURL error:NULL];
        self.shortWhistle.delegate = self;
        [self.shortWhistle prepareToPlay];
    }
    if (self.mediumWhistle == nil) {
        whistleURL = [[NSBundle mainBundle] URLForResource:@"medium_whistle" withExtension:@"caf"];
        self.mediumWhistle = [[AVAudioPlayer alloc] initWithContentsOfURL:whistleURL error:NULL];
        self.mediumWhistle.delegate = self;
        [self.mediumWhistle prepareToPlay];
    }
    if (self.loudLongWhistle == nil) {
        whistleURL = [[NSBundle mainBundle] URLForResource:@"loud_long_whistle" withExtension:@"caf"];
        self.loudLongWhistle = [[AVAudioPlayer alloc] initWithContentsOfURL:whistleURL error:NULL];
        self.loudLongWhistle.delegate = self;
        [self.loudLongWhistle prepareToPlay];
    }
}

// Deallocate memory
- (void) dealloc {
    self.recorder = nil, 
    self.timer = nil,
    self.shortWhistle = nil,
    self.toot = nil,
    self.mediumWhistle = nil,
    self.loudLongWhistle = nil,
    self.currentPlayer = nil;
    [self stopSampling];
}

@end
