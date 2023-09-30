//
//  Header.h
//  AudioLabSwift
//
//  Created by jason brown on 05/07/1402 AP.
//  Copyright © 1402 AP Eric Larson. All rights reserved.


// Class Imports
#import <Foundation/Foundation.h>

// DSPUtils Imports
#import "CircularBuffer.h"
#import "FFTHelper.h"
#import "Novocaine.h"

@interface AudioModel : NSObject

+(AudioModel*) sharedInstance;

-(void) useMicrophone;

-(void) useSpeaker:(float)withFrequency;

-(void)playAudioManager;

-(int) getSampleRate;

-(void)performFftOnAudio;

-(float*) getAudioData;

-(int) getAudioDataSize;

-(float*) getFftData;

-(int) getFftDataSize;

+(float) convertFftMagnitudeIndexToFrequency:(int)fftMagnitudeIndex;

+(int) convertFrequencyToFftMagnitudeIndex:(float)frequency;

-(float) getFftRangeWithLowerFrequencyBounds:(float)lowerFrequency andUpperFrequencyBounds:(float)upperFrequency;

-(NSArray*) getLoudestFftMagnitudeIndicesWithLowerFrequencyBounds:(float)lowerFrequency andUpperFrequencyBounds:(float)upperFrequency usingFrequencyBucketSize:(float)frequencyBucketSize;;

-(void) close;

@end
