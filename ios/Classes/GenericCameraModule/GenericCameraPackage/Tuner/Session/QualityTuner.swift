//
//  QualityTuner.swift
//  
//
//  Created by Vishal on 2024/06/10.
//

import AVFoundation

struct QualityTuner: XCamSessionTuning {
    let needTransaction = true
    var videoQuality: AVCaptureSession.Preset

    func tune<T: XCamCoreSessionRepresentable>(_ session: T) throws {
        try session.videoQuality(to: self.videoQuality)
    }
}
