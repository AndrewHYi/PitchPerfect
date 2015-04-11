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
    var echoAudioPlayer:AVAudioPlayer!
    var audioEngine:AVAudioEngine!
    var audioFile:AVAudioFile!
    var session:AVAudioSession!
    var receivedAudio:RecordedAudio!
    
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
        setAudioPlayerAndSession()
        audioPlayer.currentTime = 0
        audioPlayer.rate = 0.8
        audioPlayer.play()
    }
    @IBAction func playFastAudio(sender: UIButton) {
        setAudioPlayerAndSession()
        audioPlayer.currentTime = 0
        audioPlayer.rate = 1.4;
        audioPlayer.play()
    }
    
    @IBAction func playHighPitch(sender: UIButton) {
        setAudioPlayerAndSession()
        playAudioWithVariablePitch(1000)
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
        
        var audioPlayerNode = AVAudioPlayerNode()
        var reverbEffect = AVAudioUnitReverb()
        reverbEffect.wetDryMix = 50.0
        reverbEffect.loadFactoryPreset(AVAudioUnitReverbPreset.Cathedral)
        
        audioEngine.attachNode(audioPlayerNode)
        audioEngine.attachNode(reverbEffect)
        
        audioEngine.connect(audioPlayerNode, to: reverbEffect, format: nil)
        audioEngine.connect(reverbEffect, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        audioEngine.startAndReturnError(nil)
        audioPlayerNode.play()
    }
    
    @IBAction func playLowPitch(sender: UIButton) {
        setAudioPlayerAndSession()
        playAudioWithVariablePitch(-1000)
    }
    
    @IBAction func stopButtonPressed(sender: UIButton) {
        stopAudio()
    }
    
    func playAudioWithVariablePitch(pitch: Float) {
        var audioPlayerNode = AVAudioPlayerNode()
        var changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        
        audioEngine.attachNode(audioPlayerNode)
        audioEngine.attachNode(changePitchEffect)
        
        audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
        audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        audioEngine.startAndReturnError(nil)
        audioPlayerNode.play()
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        if(flag) { stopAudio() }
    }
    
    func setAudioPlayerAndSession() {
        audioPlayer.stop()
        audioEngine.stop()
        audioEngine.reset()
        stopButton.hidden = false
        session.setCategory(AVAudioSessionCategoryPlayback, error: nil)
    }
    
    func stopAudio() {
        stopButton.hidden = true
        if(echoAudioPlayer.playing) { echoAudioPlayer.stop() }
        if(audioPlayer.playing) { audioPlayer.stop() }
        if(audioEngine.running) {
            audioEngine.stop()
            audioEngine.reset()
        }
        audioPlayer.currentTime = 0
        session.setActive(false, error: nil)
    }

}