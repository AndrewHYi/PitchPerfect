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
    var session:AVAudioSession!
    var receivedAudio:RecordedAudio!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        session = AVAudioSession.sharedInstance()
        audioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl, error: nil)
        audioPlayer.enableRate = true
        audioPlayer.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        stopButton.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playSlowAudio(sender: UIButton) {
        setAudioSession()
        audioPlayer.stop()
        audioPlayer.currentTime = 0
        audioPlayer.rate = 0.8
        audioPlayer.play()
    }
    @IBAction func playFastAudio(sender: UIButton) {
        setAudioSession()
        audioPlayer.stop()
        audioPlayer.currentTime = 0
        audioPlayer.rate = 1.4;
        audioPlayer.play()
    }
    
    @IBAction func stopAudio(sender: UIButton) {
        stopButton.hidden = true
        audioPlayer.stop()
        audioPlayer.currentTime = 0
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        stopAudioSession()
    }
    
    func setAudioSession() {
        stopButton.hidden = false
        session.setCategory(AVAudioSessionCategoryPlayback, error: nil)
    }
    
    func stopAudioSession() {
        stopButton.hidden = true
        session.setActive(false, error: nil)
    }

}