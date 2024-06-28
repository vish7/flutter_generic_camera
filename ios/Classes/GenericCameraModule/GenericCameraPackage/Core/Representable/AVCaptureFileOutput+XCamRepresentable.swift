//
//  AVCaptureFileOutput+XCamFileOutputRepresentable.swift
//  
//
//  Created by Vishal on 2024/06/16.
//

import Foundation
import AVFoundation

protocol XCamFileOutputRepresentable {
    func stopRecording()
    func startRecording(
        to outputFileURL: URL,
        recordingDelegate delegate: AVCaptureFileOutputRecordingDelegate)
    func getConnection(with mediaType: AVMediaType) -> XCamCaptureConnectionRepresentable?
}

extension AVCaptureFileOutput: XCamFileOutputRepresentable {
    func getConnection(with mediaType: AVMediaType) -> XCamCaptureConnectionRepresentable? {
        return connection(with: mediaType)
    }
}
