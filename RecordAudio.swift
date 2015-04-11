//
//  RecordAudio.swift
//  Pitch Perfect
//
//  Created by Andrew Yi on 4/10/15.
//  Copyright (c) 2015 AndrewHYi. All rights reserved.
//

import Foundation

class RecordedAudio: NSObject {
    var filePathUrl: NSURL!
    var title: String!
    init(title: String, filePathUrl: NSURL) {
        self.title = title
        self.filePathUrl = filePathUrl
    }
}
