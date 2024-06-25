//
//  VideoStabilizationTuner.swift
//  
//
//  Created by Vishal on 2024/06/10.
//

import AVFoundation

struct VideoStabilizationTuner: XCamConnectionTuning {
    var stabilzationMode: AVCaptureVideoStabilizationMode

    func tune<T: XCamCaptureConnectionRepresentable>(_ connection: T) {
        connection.stabilizationMode(to: stabilzationMode)
    }
}
