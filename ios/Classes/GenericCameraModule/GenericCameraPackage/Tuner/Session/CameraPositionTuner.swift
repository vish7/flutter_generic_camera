//
//  CameraPositionTuner.swift
//  
//
//  Created by Vishal on 2024/06/10.
//

import AVFoundation

struct CameraPositionTuner: XCamSessionTuning {
    let needTransaction = true
    var position: AVCaptureDevice.Position
    var devicePreference: AVCaptureDevice.DeviceType?

    init(position: AVCaptureDevice.Position, devicePreference: AVCaptureDevice.DeviceType? = nil) {
        self.position = position
        self.devicePreference = devicePreference
    }

    func tune<T: XCamCoreSessionRepresentable>(_ session: T) throws {
        try session.cameraPosition(to: position, device: devicePreference)
    }
}
