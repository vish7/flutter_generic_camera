//
//  CapturePhotoProcessor.swift
//  
//
//  Created by Vishal on 2024/06/18.
//

import UIKit
import AVFoundation

struct CapturePhotoProcessor: XCamCapturePhotoOutputProcessing {
    let setting: AVCapturePhotoSettings
    let delegate: AVCapturePhotoCaptureDelegate
    let autoVideoOrientationEnabled: Bool

    func process<T>(_ output: T) throws where T: XCamPhotoOutputRepresentable {
        guard let connection = output.getConnection(with: .video) else {
            throw XCamError.session(reason: .cannotFindConnection)
        }
        
        if autoVideoOrientationEnabled {
            connection.orientation(to: UIDevice.current.orientation.toVideoOrientation)
        }

        output.capturePhoto(with: setting, delegate: delegate)
    }
}
