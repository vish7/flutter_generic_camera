//
//  File.swift
//  
//
//  Created by Vishal on 2024/06/10.
//

import AVFoundation

struct AudioTuner: XCamSessionTuning {
    let needTransaction = true
    var isMuted: Bool // default zoom factor

    func tune<T: XCamCoreSessionRepresentable>(_ session: T) throws {
        if isMuted {
            session.removeAudioInput()
        } else {
            try session.addAudioInput()
        }
    }
}
