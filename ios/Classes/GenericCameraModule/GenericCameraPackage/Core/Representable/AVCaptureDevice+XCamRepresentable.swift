//
//  XCamCaptureDeviceRepresentable.swift
//  
//
//  Created by Vishal on 2024/06/16.
//

import Foundation
import AVFoundation

protocol XCamCaptureDeviceRepresentable {
    var hasTorch: Bool { get }
    var focusMode: AVCaptureDevice.FocusMode { get set }
    var isSubjectAreaChangeMonitoringEnabled: Bool { get set }
    var flashMode: AVCaptureDevice.FlashMode { get set }
    var videoZoomFactor: CGFloat { get set }

    var maxResolution: Double? { get }
    
    func isFocusModeSupported(_ focusMode: AVCaptureDevice.FocusMode) -> Bool

    func zoomFactor(_ factor: CGFloat)
    func setFocusMode(_ focusMode: AVCaptureDevice.FocusMode, point: CGPoint?) throws
    func torchMode(_ torchMode: AVCaptureDevice.TorchMode)
    func enableMonitoring(_ enabled: Bool)
    func setTorchModeOn(level torchLevel: Float) throws
}

extension AVCaptureDevice: XCamCaptureDeviceRepresentable {
    func torchMode(_ torchMode: TorchMode) {
        switch torchMode {
        case .off:
            self.torchMode = .off
        case .on:
            self.torchMode = .on
        case .auto:
            self.torchMode = .auto
        @unknown default:
            self.torchMode = .off
        }
    }
    
    func enableMonitoring(_ enabled: Bool) {
        self.isSubjectAreaChangeMonitoringEnabled = enabled
    }

    func setFocusMode(_ focusMode: AVCaptureDevice.FocusMode, point: CGPoint?) throws {
        if isAdjustingFocus {
            throw XCamError.device(reason: .busy)
        }
        
        if isFocusModeSupported(focusMode) {
            self.focusMode = focusMode
        } else {
            throw XCamError.device(reason: .notSupported)
        }
        
        if isFocusPointOfInterestSupported {
            if let point { self.focusPointOfInterest = point }
        } else {
            throw XCamError.device(reason: .notSupported)
        }
    }

    func zoomFactor(_ factor: CGFloat) {
        self.videoZoomFactor = factor
    }

    var maxResolution: Double? {
        var maxResolution: Double = 0
        for format in self.formats {
            let dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
            let resolution = Double(dimensions.width * dimensions.height)
            maxResolution = max(resolution, maxResolution)
        }
        return maxResolution
    }
}
