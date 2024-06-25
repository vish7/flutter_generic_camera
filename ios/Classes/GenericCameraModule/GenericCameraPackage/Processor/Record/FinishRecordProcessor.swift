//
//  FinishRecordingProcessor.swift
//  
//
//  Created by Vishal on 2024/06/10.
//

import AVFoundation

struct FinishRecordProcessor: XCamMovieFileOutputProcessing {
    func process<T: XCamFileOutputRepresentable>(_ output: T) throws {
        output.stopRecording()
    }
}
