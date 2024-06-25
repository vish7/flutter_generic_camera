//
//  TorchTuner.swift
//  
//
//  Created by Vishal on 2024/06/17.
//

import Foundation
import AVFoundation

struct TorchTuner: XCamDeviceTuning {
    let level: Float
    let torchMode: AVCaptureDevice.TorchMode

    func tune<T>(_ device: T) throws where T: XCamCaptureDeviceRepresentable {
        guard device.hasTorch else {
            throw XCamError.device(reason: .notSupported)
        }

        device.torchMode(torchMode)
        //try device.setTorchModeOn(level: level)
    }
}
