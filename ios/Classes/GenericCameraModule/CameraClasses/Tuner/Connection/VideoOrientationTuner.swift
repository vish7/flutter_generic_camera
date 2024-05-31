//
//  VideoOrientationTuner.swift
//  
//
//  Created by 이영빈 on 2023/06/02.
//

import AVFoundation

struct VideoOrientationTuner: AespaConnectionTuning {
    var orientation: AVCaptureVideoOrientation

    func tune<T: AespaCaptureConnectionRepresentable>(_ connection: T) throws {
        guard connection.isVideoOrientationSupported else {
            throw AespaError.connection(reason: .cannotChangeVideoOrientation)
        }
        
        connection.orientation(to: orientation)
    }
}
