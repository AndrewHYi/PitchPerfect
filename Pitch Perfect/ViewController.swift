//
//  ViewController.swift
//  Pitch Perfect
//
//  Created by Andrew H. Yi on 4/4/15.
//  Copyright (c) 2015 AndrewHYi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var recordingInProgress: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        recordButton.enabled = true
        stopButton.hidden = true;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func recordAudio(sender: UIButton) {
        recordButton.enabled = false;
        recordingInProgress.hidden = false;
        stopButton.hidden = false;
    }

    @IBAction func stopRecording(sender: UIButton) {
        recordingInProgress.hidden = true;
        stopButton.hidden = true;
    }

}

