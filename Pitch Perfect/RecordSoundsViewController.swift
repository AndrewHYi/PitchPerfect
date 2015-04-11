//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Andrew H. Yi on 4/4/15.
//  Copyright (c) 2015 AndrewHYi. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var recordingStatusText: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    var paused:Bool?
    
    var audioRecorder:AVAudioRecorder!
    var recordedAudio:RecordedAudio!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        recordingStatusText.text = "Tap to Record"
        recordButton.enabled = true
        stopButton.hidden = true;
        pauseButton.hidden = true;
        paused = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func recordAudio(sender: UIButton) {
        recordButton.enabled = false;
        recordingStatusText.text = "Recording..."
        recordingStatusText.hidden = false;
        stopButton.hidden = false;
        pauseButton.enabled = true;
        pauseButton.hidden = false;
        
        if(paused == false) {
            let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
            let currentDateTime = NSDate()
            let formatter = NSDateFormatter()
            formatter.dateFormat = "ddMMyyyy-HHmmss"
            let recordingName = formatter.stringFromDate(currentDateTime)+".wav"
            let pathArray = [dirPath, recordingName]
            let filePath = NSURL.fileURLWithPathComponents(pathArray)
            
            var session = AVAudioSession.sharedInstance()
            session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
            
            audioRecorder = AVAudioRecorder(URL: filePath, settings: nil, error: nil)
            audioRecorder.delegate = self
            audioRecorder.meteringEnabled = true
        }
        audioRecorder.record()
        paused = false
    }

    @IBAction func stopRecording(sender: UIButton) {
        stopButton.hidden = true;
        pauseButton.hidden = true;
        audioRecorder.stop()
        var audioSession = AVAudioSession.sharedInstance()
        audioSession.setActive(false, error: nil)
    }
    
    @IBAction func pauseRecording(sender: UIButton) {
        paused = true
        recordButton.enabled = true
        recordingStatusText.text = "Paused\n(Press Mic to Resume)"
        pauseButton.enabled = false
        audioRecorder.pause()
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        if(flag) {
            recordedAudio = RecordedAudio(title: recorder.url.lastPathComponent!, filePathUrl: recorder.url)
            self.performSegueWithIdentifier("stopRecording", sender: recordedAudio)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "stopRecording") {
            let vc:PlaySoundsViewController = segue.destinationViewController as! PlaySoundsViewController
            let audioData = sender as! RecordedAudio
            vc.receivedAudio = audioData
        }
    }

}

