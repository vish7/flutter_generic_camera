//
//  VideoOrientationTuner.swift
//  
//
//  Created by Vishal on 2024/06/10.
//

import AVFoundation

struct VideoOrientationTuner: XCamConnectionTuning {
    var orientation: AVCaptureVideoOrientation

    func tune<T: XCamCaptureConnectionRepresentable>(_ connection: T) throws {
        guard connection.isVideoOrientationSupported else {
            throw XCamError.connection(reason: .cannotChangeVideoOrientation)
        }
        
        connection.orientation(to: orientation)
    }
}
