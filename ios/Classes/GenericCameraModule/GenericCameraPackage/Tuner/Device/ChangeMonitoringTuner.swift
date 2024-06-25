//
//  ChangeMonitoringTuner.swift
//  
//
//  Created by Vishal on 2024/06/28.
//

import Foundation
import AVFoundation

struct ChangeMonitoringTuner: XCamDeviceTuning {
    let needLock = true
    
    let enabled: Bool
    
    init(isSubjectAreaChangeMonitoringEnabled: Bool) {
        self.enabled = isSubjectAreaChangeMonitoringEnabled
    }

    func tune<T: XCamCaptureDeviceRepresentable>(_ device: T) throws {
        device.enableMonitoring(enabled)
    }
}
