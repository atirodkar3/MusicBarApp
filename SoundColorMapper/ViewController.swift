//
//  ViewController.swift
//  SoundColorMapper
//
//  Created by Tirodkar, Aditya on 12/11/14.
//  Copyright (c) 2014 Tirodkar, Aditya. All rights reserved.
//

import UIKit
import AVFoundation

class PowerLevel {
    var totalLevelCalculated : NSNumber = 0
    var totalInstances : NSNumber = 0
    
    init(totalLevelCalculated : NSNumber, totalInstances : NSNumber) {
        self.totalLevelCalculated = 0
        self.totalInstances = 0
    }
    
    func addLevelCalculation(calculation : NSNumber, forInstance instance : NSNumber) -> Void {
        totalLevelCalculated = totalLevelCalculated.floatValue + calculation.floatValue
        totalInstances = totalInstances.floatValue + instance.floatValue
    }
    
    func averagePowerCalculation() -> NSNumber {
        return totalLevelCalculated.floatValue / totalInstances.floatValue
    }
}

class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    var audioRecorder : AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var meterTimer : NSTimer!
    var maxRecordingPowerLevel : PowerLevel = PowerLevel(totalLevelCalculated: 0, totalInstances: 0)
    @IBOutlet weak var backgroundView : UIView!
    @IBOutlet weak var recordButton : UIButton!
    @IBOutlet weak var playButton : UIButton!
    @IBOutlet weak var stopButton : UIButton!
    @IBOutlet weak var powerBar1 : PowerBar!
    @IBOutlet weak var powerBar2 : PowerBar!
    @IBOutlet weak var powerBar3 : PowerBar!
    @IBOutlet weak var powerBar4 : PowerBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playButton.enabled = false;
        stopButton.enabled = false;
        
        var dirPaths : NSArray
        var docsDir : NSString
        
        dirPaths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        docsDir = dirPaths[0] as NSString
        
        var soundsFilePath = docsDir + "/sound.caf"
        var soundFileURL = NSURL(fileURLWithPath: soundsFilePath)
        
        var recordSettings = [NSNumber(integer: AVAudioQuality.Min.rawValue):AVEncoderAudioQualityKey,
            NSNumber(integer: 16):AVEncoderBitRateKey,
            NSNumber(integer: 2):AVNumberOfChannelsKey,
            NSNumber(float: 44100.0):AVSampleRateKey
        ]
        
        var error : NSError?
        
        var audioSession : AVAudioSession = AVAudioSession.sharedInstance()
        audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
        
        audioRecorder = AVAudioRecorder(URL: soundFileURL!, settings: recordSettings, error: &error)
        
        if (error != nil) {
            println("error " + error!.localizedDescription)
        } else {
            audioRecorder.prepareToRecord()
        }
    }
    
    @IBAction func recordAudio(sender: AnyObject) {
        if (!self.audioRecorder.recording) {
            playButton.enabled = false
            stopButton.enabled = true
            audioRecorder.record()
            
            self.audioRecorder.meteringEnabled = true
            self.startAudioMetering(true)
        }
    }
    
    @IBAction func playAudio(sender: AnyObject) {
        if (!audioRecorder.recording) {
            stopButton.enabled = true
            recordButton.enabled = false
            
            var error:NSError?
            
            audioPlayer = AVAudioPlayer(contentsOfURL: audioRecorder.url, error: &error)
            
            audioPlayer.delegate = self
            
            self.audioPlayer.meteringEnabled = true
            
            if (error != nil) {
                println("error " + error!.localizedDescription)
            } else {
                audioPlayer.play()
                self.startAudioMetering(false)
            }
        }
    }
    
    @IBAction func stopAudio(sender: AnyObject) {
        stopButton.enabled = false
        playButton.enabled = true
        recordButton.enabled = true
        
        if (audioRecorder.recording) {
            audioRecorder.stop()
        } else if (audioPlayer.playing){
            audioPlayer.stop()
        }
        
        self.stopAudioMetering()
        backgroundView.backgroundColor = UIColor.whiteColor()
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        recordButton.enabled = true
        stopButton.enabled = true
        self.stopAudioMetering()
        backgroundView.backgroundColor = UIColor.whiteColor()
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer!, error: NSError!) {
        println("Decode Error Occurred")
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        self.stopAudioMetering()
    }
    
    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder!, error: NSError!) {
        println("Encode Error Occurred")
    }
    
    func startAudioMetering(isRecorder : Bool) -> Void {
        self.meterTimer = NSTimer.scheduledTimerWithTimeInterval(0.1,
            target: self,
            selector: isRecorder ? Selector("calculatePowerLevel") : Selector("displayMeterValue"),
            userInfo: nil,
            repeats: true
        )
    }

    func stopAudioMetering() -> Void {
        self.meterTimer.invalidate()
    }
    
    func calculatePowerLevel() -> Void {
        self.audioRecorder.updateMeters()
        //println("Red %f %f", self.audioRecorder.averagePowerForChannel(1), self.audioRecorder.peakPowerForChannel(0))
        //var averageChannelPower : NSNumber = abs((self.audioRecorder.averagePowerForChannel(0) + self.audioRecorder.peakPowerForChannel(0)) / 2)
        maxRecordingPowerLevel.addLevelCalculation(abs(self.audioRecorder.peakPowerForChannel(0)), forInstance: 1)
    }
    
    func displayMeterValue() -> Void {
        self.audioPlayer.updateMeters()
        
        //println("Val %f %f", self.audioPlayer.averagePowerForChannel(0), self.audioPlayer.peakPowerForChannel(0))
        
        //var averagePower : NSNumber = abs((self.audioPlayer.averagePowerForChannel(0) + self.audioPlayer.peakPowerForChannel(0)) / 2)
        var percentage : NSNumber = abs(self.audioPlayer.averagePowerForChannel(0)) / 160.0
        self.powerBar1.animateToHeightPercentage(percentage)
        self.powerBar2.animateToHeightPercentage(percentage)
        self.powerBar3.animateToHeightPercentage(percentage)
        self.powerBar4.animateToHeightPercentage(percentage)
        
        UIView.animateWithDuration(0.5, animations: {self.backgroundView.backgroundColor = UIColor.blueColor()}, completion: nil)
        
        
        //backgroundView.backgroundColor = UIColor.blueColor()
        
        //backgroundView.alpha = CGFloat(self.audioPlayer.peakPowerForChannel(0)  * (255.0 / maxRecordingPowerLevel.averagePowerCalculation().floatValue)) / 255.0
        
//        println("alpha %f", (averagePower.floatValue  * (255.0 / maxRecordingPowerLevel.averagePowerCalculation().floatValue)) / 255.0 as Float)
    }
}

