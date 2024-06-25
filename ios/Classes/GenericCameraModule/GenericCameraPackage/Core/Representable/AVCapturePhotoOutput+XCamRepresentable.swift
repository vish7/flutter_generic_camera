//
//  AVCapturePhotoOutput+XCamRepresentable.swift
//  
//
//  Created by Young Bin on 2024/06/18.
//

import Foundation
import AVFoundation

protocol XCamPhotoOutputRepresentable {
    func capturePhoto(with: AVCapturePhotoSettings, delegate: AVCapturePhotoCaptureDelegate)
    func getConnection(with mediaType: AVMediaType) -> XCamCaptureConnectionRepresentable?
}

extension AVCapturePhotoOutput: XCamPhotoOutputRepresentable {
    func getConnection(with mediaType: AVMediaType) -> XCamCaptureConnectionRepresentable? {
        return connection(with: mediaType)
    }
}
