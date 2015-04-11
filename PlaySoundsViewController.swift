//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Andrew H. Yi on 4/9/15.
//  Copyright (c) 2015 AndrewHYi. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController, AVAudioPlayerDelegate {

    @IBOutlet weak var stopButton: UIButton!
    
    var audioPlayer:AVAudioPlayer!
    var audioPlayerNode:AVAudioPlayerNode!
    var echoAudioPlayer:AVAudioPlayer!
    var audioEngine:AVAudioEngine!
    var audioFile:AVAudioFile!
    var session:AVAudioSession!
    var receivedAudio:RecordedAudio!
    var timer:NSTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        session = AVAudioSession.sharedInstance()
        audioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl, error: nil)
        audioPlayer.enableRate = true
        audioPlayer.delegate = self
        
        audioFile = AVAudioFile(forReading: receivedAudio.filePathUrl, error: nil)
        audioEngine = AVAudioEngine()
    }
    
    override func viewWillAppear(animated: Bool) {
        stopButton.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playSlowAudio(sender: UIButton) {
        playAudioWithVariableRate(0.8)
    }
    @IBAction func playFastAudio(sender: UIButton) {
        playAudioWithVariableRate(1.4)
    }
    
    @IBAction func playHighPitch(sender: UIButton) {
        playAudioWithVariablePitch(1000)
    }
    
    @IBAction func playLowPitch(sender: UIButton) {
        playAudioWithVariablePitch(-1000)
    }
    
    @IBAction func playEcho(sender: UIButton) {
        setAudioPlayerAndSession()
        
        // play audioPlayer with delay instead of echoAudioPlayer so that audioPlayerDidFinishPlaying is still correct
        // (Otherwise the audio will stop too early)
        echoAudioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl, error: nil)
        audioPlayer.volume = 0.6;
        
        echoAudioPlayer.play()
        audioPlayer.playAtTime(echoAudioPlayer.deviceCurrentTime + 0.45)
    }
    
    @IBAction func playReverb(sender: AnyObject) {
        setAudioPlayerAndSession()
        
        audioPlayerNode = AVAudioPlayerNode()
        var reverbEffect = AVAudioUnitReverb()
        reverbEffect.wetDryMix = 50.0
        reverbEffect.loadFactoryPreset(AVAudioUnitReverbPreset.Cathedral)
        
        audioEngine.attachNode(audioPlayerNode)
        audioEngine.attachNode(reverbEffect)
        
        audioEngine.connect(audioPlayerNode, to: reverbEffect, format: nil)
        audioEngine.connect(reverbEffect, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil) {
            let playerTime = self.audioPlayerNode.playerTimeForNodeTime(self.audioPlayerNode.lastRenderTime)
            let delayInSeconds: Double = {
                if playerTime != nil {
                    // This is a hack...This is 'Good enough'™ to hide the stopButton for the reverb effect, but ideally
                    // I would get get the correct length of the audio (with reverb effect added)
                    return Double(self.audioFile.length - playerTime.sampleTime) / self.audioFile.processingFormat.sampleRate / Double(self.audioPlayer.rate) + Double(0.45)
                } else {
                    return 0
                }
                }()
            self.timer = NSTimer(timeInterval: delayInSeconds, target: self, selector: "stopAudio", userInfo: nil, repeats: false)
            NSRunLoop.mainRunLoop().addTimer(self.timer!, forMode: NSDefaultRunLoopMode)
        }
        audioEngine.startAndReturnError(nil)
        audioPlayerNode.play()
    }
    
    @IBAction func stopButtonPressed(sender: UIButton) {
        stopAudio()
    }
    
    func playAudioWithVariableRate(rate: Float) {
        setAudioPlayerAndSession()
        audioPlayer.rate = rate
        audioPlayer.play()
    }
    
    func playAudioWithVariablePitch(pitch: Float) {
        setAudioPlayerAndSession()
        audioPlayerNode = AVAudioPlayerNode()
        var changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        
        audioEngine.attachNode(audioPlayerNode)
        audioEngine.attachNode(changePitchEffect)
        
        audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
        audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: nil)
       
        audioPlayerNode.scheduleFile(audioFile, atTime: nil) {
            let playerTime = self.audioPlayerNode.playerTimeForNodeTime(self.audioPlayerNode.lastRenderTime)
            let delayInSeconds: Double = {
                if playerTime != nil {
                    return Double(self.audioFile.length - playerTime.sampleTime) / self.audioFile.processingFormat.sampleRate / Double(self.audioPlayer.rate)
                } else {
                    return 0
                }
            }()
            self.timer = NSTimer(timeInterval: delayInSeconds, target: self, selector: "stopAudio", userInfo: nil, repeats: false)
            NSRunLoop.mainRunLoop().addTimer(self.timer!, forMode: NSDefaultRunLoopMode)
        }
        audioEngine.startAndReturnError(nil)
        audioPlayerNode.play()
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        if(flag) { stopAudio() }
    }
    
    func setAudioPlayerAndSession() {
        audioPlayer.stop()
        audioPlayer.currentTime = 0
        audioEngine.stop()
        audioEngine.reset()
        stopButton.hidden = false
        session.setCategory(AVAudioSessionCategoryPlayback, error: nil)
    }
    
    func stopAudio() {
        stopButton.hidden = true
        if(echoAudioPlayer != nil && echoAudioPlayer.playing) { echoAudioPlayer.stop() }
        if(audioPlayer.playing) { audioPlayer.stop() }
        if(audioEngine.running) {
            audioEngine.stop()
            audioEngine.reset()
        }
        audioPlayer.currentTime = 0
        session.setActive(false, error: nil)
    }

}