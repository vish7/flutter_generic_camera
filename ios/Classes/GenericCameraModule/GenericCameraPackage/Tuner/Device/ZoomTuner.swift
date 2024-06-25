//
//  ZoomTuner.swift
//  
//
//  Created by Vishal on 2024/06/10.
//

import AVFoundation

struct ZoomTuner: XCamDeviceTuning {
    var needLock = true
    var zoomFactor: CGFloat

    func tune<T: XCamCaptureDeviceRepresentable>(_ device: T) {
        device.zoomFactor(zoomFactor)
    }
}
