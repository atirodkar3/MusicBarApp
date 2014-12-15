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
    var minPowerLevel : NSNumber!
    var maxPowerLevel : NSNumber!
    
    init(minPowerLevel : NSNumber, maxPowerLevel : NSNumber) {
        self.minPowerLevel = NSIntegerMax
        self.maxPowerLevel = 0
    }
    
    func addLevelCalculation(level : NSNumber) -> Void {
        if (level.floatValue < minPowerLevel.floatValue) {
            self.minPowerLevel = level.floatValue
        } else if (level.floatValue >= maxPowerLevel.floatValue) {
            self.maxPowerLevel = level.floatValue
        }
    }
}

class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    var audioRecorder : AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var meterTimer : NSTimer!
    var maxRecordingPowerLevel : PowerLevel = PowerLevel(minPowerLevel: NSIntegerMax, maxPowerLevel: 0)
    var levelCalculator : PowerBarLevelCalculator!
    
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
            self.levelCalculator = PowerBarLevelCalculator(
                maxLevel: self.maxRecordingPowerLevel.maxPowerLevel,
                minLevel: self.maxRecordingPowerLevel.minPowerLevel,
                numberOfBars: 4)
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
        maxRecordingPowerLevel.addLevelCalculation(abs(self.audioRecorder.peakPowerForChannel(0)))
    }
    
    func displayMeterValue() -> Void {
        self.audioPlayer.updateMeters()
        var percentage : NSNumber = abs(self.audioPlayer.averagePowerForChannel(0)) / 160.0
        println("LEVEL %f",self.levelCalculator.powerLevelforValue(abs(self.audioPlayer.averagePowerForChannel(0))))
        
        var level : NSNumber = self.levelCalculator.powerLevelforValue(abs(self.audioPlayer.averagePowerForChannel(0)))
        
        switch (level) {
        case 1 : self.powerBar1.animateToHeightPercentage(percentage)
        case 2 : self.powerBar2.animateToHeightPercentage(percentage)
        case 3 : self.powerBar3.animateToHeightPercentage(percentage)
        case 4 : self.powerBar4.animateToHeightPercentage(percentage)
        default:  self.powerBar4.animateToHeightPercentage(percentage)
        }
        
        self.animateBackground(level)
    }
    
    func animateBackground(value : NSNumber) -> Void {
        
        switch value {
        case 1 : UIView.animateWithDuration(0.5, animations: {self.backgroundView.backgroundColor = UIColor.blueColor()}, completion: nil)
        case 2 : UIView.animateWithDuration(0.5, animations: {self.backgroundView.backgroundColor = UIColor.greenColor()}, completion: nil)
        case 3 : UIView.animateWithDuration(0.5, animations: {self.backgroundView.backgroundColor = UIColor.yellowColor()}, completion: nil)
        case 4 : UIView.animateWithDuration(0.5, animations: {self.backgroundView.backgroundColor = UIColor.orangeColor()}, completion: nil)
        default : UIView.animateWithDuration(0.5, animations: {self.backgroundView.backgroundColor = UIColor.purpleColor()}, completion: nil)
        }
        
        
        
    }
}

