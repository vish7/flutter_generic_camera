//
//  FocusTuner.swift
//  
//
//  Created by Young Bin on 2024/06/10.
//

import UIKit
import Foundation
import AVFoundation

struct FocusTuner: XCamDeviceTuning {
    let needLock = true
    
    let mode: AVCaptureDevice.FocusMode
    let point: CGPoint?

    func tune<T: XCamCaptureDeviceRepresentable>(_ device: T) throws {
        guard device.isFocusModeSupported(mode) else {
            throw XCamError.device(reason: .notSupported)
        }

        try device.setFocusMode(mode, point: point)
    }
}
