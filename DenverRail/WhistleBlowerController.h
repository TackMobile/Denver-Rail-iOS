//
//  WhistleBlowerController.h
//  DenverRail
//
// 2008 - 2013 Tack Mobile.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSUInteger, WhistleBlowerState) {
    WhistleBlowerStateNoWhistleYet = 0,
    WhistleBlowerStateOneWhistle,
    WhistleBlowerStateMultipleWhistles,
};

@interface WhistleBlowerController : NSObject<AVAudioPlayerDelegate> {
    double lastSample;
    int ticksSinceLastWhistle;
    BOOL whistlePlaying;
}

@property WhistleBlowerState currentState;
@property(nonatomic) BOOL isOn;
- (void)putYourLipsTogetherAndBlow;

@end
