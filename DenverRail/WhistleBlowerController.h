//
//  WhistleBlowerController.h
//  DenverRail
//
// 2008 - 2013 Tack Mobile.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

enum WhistleBlowerState {
    WhistleBlowerStateNoWhistleYet = 0,
    WhistleBlowerStateOneWhistle = 1,
    WhistleBlowerStateMultipleWhistles = 2
};


@interface WhistleBlowerController : NSObject<AVAudioPlayerDelegate> {
    enum WhistleBlowerState state;
    double lastSample;
    int ticksSinceLastWhistle;
    BOOL whistlePlaying;
}

@property(nonatomic) BOOL on;
@property(nonatomic, strong) AVAudioRecorder *recorder;
@property(nonatomic, strong) NSTimer *timer;
@property(nonatomic, strong) AVAudioPlayer *toot;
@property(nonatomic, strong) AVAudioPlayer *shortWhistle;
@property(nonatomic, strong) AVAudioPlayer *mediumWhistle;
@property(nonatomic, strong) AVAudioPlayer *loudLongWhistle;
@property(nonatomic, strong) AVAudioPlayer *currentPlayer;

- (void) putYourLipsTogetherAndBlow;

@end
