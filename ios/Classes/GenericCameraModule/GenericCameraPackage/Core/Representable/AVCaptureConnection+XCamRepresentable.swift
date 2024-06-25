//
//  File.swift
//  
//
//  Created by Vishal on 2024/06/16.
//

import Foundation
import AVFoundation

protocol XCamCaptureConnectionRepresentable {
    var videoOrientation: AVCaptureVideoOrientation { get set }
    var preferredVideoStabilizationMode: AVCaptureVideoStabilizationMode { get set }
    var isVideoOrientationSupported: Bool { get }

    func orientation(to orientation: AVCaptureVideoOrientation)
    func stabilizationMode(to mode: AVCaptureVideoStabilizationMode)
}

extension AVCaptureConnection: XCamCaptureConnectionRepresentable {
    func orientation(to orientation: AVCaptureVideoOrientation) {
        self.videoOrientation = orientation
    }

    func stabilizationMode(to mode: AVCaptureVideoStabilizationMode) {
        self.preferredVideoStabilizationMode = mode
    }
}
