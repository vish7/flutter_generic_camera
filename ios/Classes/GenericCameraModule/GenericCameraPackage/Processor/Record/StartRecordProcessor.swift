//
//  RecordingStarter.swift
//  
//
//  Created by Vishal on 2024/06/10.
//

import UIKit
import AVFoundation

struct StartRecordProcessor: XCamMovieFileOutputProcessing {
    let filePath: URL
    let delegate: AVCaptureFileOutputRecordingDelegate
    let autoVideoOrientationEnabled: Bool

    func process<T: XCamFileOutputRepresentable>(_ output: T) throws {
        guard let connection = output.getConnection(with: .video) else {
            throw XCamError.session(reason: .cannotFindConnection)
        }
        
        if autoVideoOrientationEnabled {
            connection.orientation(to: UIDevice.current.orientation.toVideoOrientation)
        }

        output.startRecording(to: filePath, recordingDelegate: delegate)
    }
}
