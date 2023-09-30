//
//  AudioModel.swift
//  AudioLabSwift
//
//  Created by Eric Larson 
//  Copyright © 2020 Eric Larson. All rights reserved.
//

import Foundation
import Accelerate


class AudioModel {
    
    // MARK: Properties
    private var BUFFER_SIZE:Int
    private var SAMPLE_RATE: Int
    private var fftMagnitudeIndex: Int
    // thse properties are for interfaceing with the API
    // the user can access these arrays at any time and plot them if they like
    var timeData:[Float]
    var fftData:[Float]
    
    // MARK: Public Methods
    init(buffer_size:Int) {
        BUFFER_SIZE = buffer_size
        SAMPLE_RATE = 44100
        // anything not lazily instatntiated should be allocated here
        timeData = Array.init(repeating: 0.0, count: BUFFER_SIZE)
        fftData = Array.init(repeating: 0.0, count: BUFFER_SIZE/2)
    }
    
    // public function for starting processing of microphone data
    func startMicrophoneProcessing(withFps:Double){
        // setup the microphone to copy to circualr buffer
        if let manager = self.audioManager{
            manager.inputBlock = self.handleMicrophone
            
            // repeat this fps times per second using the timer class
            //   every time this is called, we update the arrays "timeData" and "fftData"
            Timer.scheduledTimer(withTimeInterval: 1.0/withFps, repeats: true) { _ in
                self.runEveryInterval()
            }
            
        }
    }
    
    
    // You must call this when you want the audio to start being handled by our model
    func play(){
        if let manager = self.audioManager{
            manager.play()
        }
    }
    
    
    //==========================================
    // MARK: Private Properties
    private lazy var audioManager:Novocaine? = {
        return Novocaine.audioManager()
    }()
    
    private lazy var fftHelper:FFTHelper? = {
        return FFTHelper.init(fftSize: Int32(BUFFER_SIZE))
    }()
    
    
    private lazy var inputBuffer:CircularBuffer? = {
        return CircularBuffer.init(numChannels: Int64(self.audioManager!.numInputChannels),
                                   andBufferSize: Int64(BUFFER_SIZE))
    }()
    
    
    //==========================================
    // MARK: Private Methods
    // NONE for this model
    
    //==========================================
    // MARK: Model Callback Methods
    private func runEveryInterval(){
        if inputBuffer != nil {
            // copy time data to swift array
            self.inputBuffer!.fetchFreshData(&timeData,
                                             withNumSamples: Int64(BUFFER_SIZE))
            
            // now take FFT
            fftHelper!.performForwardFFT(withData: &timeData,
                                         andCopydBMagnitudeToBuffer: &fftData)
            
            // at this point, we have saved the data to the arrays:
            //   timeData: the raw audio samples
            //   fftData:  the FFT of those same samples
            // the user can now use these variables however they like
            
        }
    }
    
    //==========================================
    // MARK: Audiocard Callbacks
    // in obj-C it was (^InputBlock)(float *data, UInt32 numFrames, UInt32 numChannels)
    // and in swift this translates to:
    private func handleMicrophone (data:Optional<UnsafeMutablePointer<Float>>, numFrames:UInt32, numChannels: UInt32) {
        // copy samples from the microphone into circular buffer
        self.inputBuffer?.addNewFloatData(data, withNumSamples: Int64(numFrames))
    }
    
    func  convertFftMagnitudeIndexToFrequency(fftMagnitudeIndex: Int) -> Float  {
        return Float(fftMagnitudeIndex * (SAMPLE_RATE/2) / (BUFFER_SIZE/2));
    }

    /*!
    @brief Static function that converts a Frequency to an FFT Magnitude Index (for the fftData array)
    */
    var res = 0;
    func convertFrequencyToFftMagnitudeIndex(frequency: Float)  -> Int{
        res = frequency * (BUFFER_SIZE/2) / (Float(SAMPLE_RATE)/2);
        return Int(res)
    }

    /*!
    @brief Finds the range of the FFT signal between a lower and upper frequency using the optimized vDSP library; returns the difference between the greatest and lowest FFT magnitude
    */
    var lowerBounds = 0.0;
    var upperBounds = 0.0;
    var minVal = 0.0;
    func getFftRangeWithLowerFrequencyBounds(lowerFrequency: Int) -> Float{
        func andUpperFrequencyBounds(upperFrequency: Float) -> Float {
            
            // converts the frequency bounds into an FFT Magnitude Index
            lowerBounds = Float(convertFrequencyToFftMagnitudeIndex(frequency: Float(lowerFrequency)))
            
            
            // uses DSP to quickly find the max and min of the signal
            minVal  = 0
            vDSP_minv(self.fftData+lowerBounds, 1, &minVal, vDSP_Length(upperBounds-lowerBounds));
            // converts the frequency bounds into an FFT Magnitude Index
            
            upperBounds = Double(convertFrequencyToFftMagnitudeIndex(frequency: upperFrequency));
            
            // uses DSP to quickly find the max and min of the signal
            maxVal = 0;
            vDSP_maxv((fftData+lowerBounds), 1, &maxVal, vDSP_Length(upperBounds-lowerBounds));
            return maxVal;
        }
    }
    /*!
    @brief Finds the two loudest fftMagnitudes between a lower and upper frequency and returns them as an NSArray*
    */
    func getLoudestFftMagnitudeIndicesWithLowerFrequencyBounds(lowerFrequency: Float) -> NSArray* {
        func andUpperFrequencyBounds(upperFrequency: Float) -> NSArray*{
            
            func usingFrequencyBucketSize(frequencyBucketSize: Float) -> NSArray*{
                
                // converts the frequency bounds into an FFT Magnitude Index
                int lowerBounds = [AnalyzerModel convertFrequencyToFftMagnitudeIndex:lowerFrequency];
                int upperBounds = [AnalyzerModel convertFrequencyToFftMagnitudeIndex:upperFrequency];
                
                // fft Magnitude Variables
                float fftMagnitude1 = -1000;
                float fftMagnitude2 = -1000;
                int fftMagnitudeIndex1 = 0;
                int fftMagnitudeIndex2 = 100;
                
                // bucket Variables
                int bucketSize = [AnalyzerModel convertFrequencyToFftMagnitudeIndex:frequencyBucketSize];
                int bucketIndexCount = 0; // Var to track bucket overflow; when bucket fills, evaluate local bucket max
                int bucketMaxIndex = 0; // Var to track local bucket max
                
                // logic for finding two maximum magnitudes
                for (int i = lowerBounds; i < upperBounds; i++)
                {
                    // If bucket count overflow (or loop has finished), evaluate local bucket max relative to loudest fft magnitude
                    if (bucketIndexCount == bucketSize || i == FFT_SIZE-1)
                    {
                        // loudest magnitude evaluation
                        if (fftMagnitude1 < self.fftData[bucketMaxIndex])
                        {
                            // set fftMagnitude2 variables to previous fftMagnitude1 variables if the bucketMaxIndex is not too close to previous fftMagnitude1
                            if (!(bucketMaxIndex < (fftMagnitudeIndex1 + bucketSize/2) && bucketMaxIndex > (fftMagnitudeIndex1 - bucketSize/2)))
                            {
                                fftMagnitudeIndex2 = fftMagnitudeIndex1;
                                fftMagnitude2 = fftMagnitude1;
                            }
                            fftMagnitudeIndex1 = bucketMaxIndex;
                            fftMagnitude1 = self.fftData[bucketMaxIndex];
                        }
                        // 2nd loudest magnitude evaluation; fftMagnitude2 cannot be too close to fftMagnitude1
                        else if (fftMagnitude2 <  self.fftData[bucketMaxIndex] && !(bucketMaxIndex < (fftMagnitudeIndex1 + bucketSize/2) && bucketMaxIndex > (fftMagnitudeIndex1 - bucketSize/2)))
                        {
                            fftMagnitudeIndex2 = bucketMaxIndex;
                            fftMagnitude2 = self.fftData[bucketMaxIndex];
                        }
                        // reset bucket for next bucket window
                        bucketIndexCount = 0;
                        bucketMaxIndex = i;
                    }
                    
                    // calculate local bucket maximum
                    if ( self.fftData[bucketMaxIndex] <  self.fftData[i])
                    {
                        bucketMaxIndex = i;
                    }
                    bucketIndexCount++; // increment bucket count
                }
                
                // return NSArray of the two magnitudes
                NSArray* fftMagnitudeIndices = @[@(fftMagnitudeIndex1), @(fftMagnitudeIndex2)];
                return fftMagnitudeIndices;
            }
        }
        
    
    
}

