//
//  SessionTerminationTuner.swift
//  
//
//  Created by Young Bin on 2024/06/10.
//

import AVFoundation

struct SessionTerminationTuner: XCamSessionTuning {
    let needTransaction = false

    func tune<T: XCamCoreSessionRepresentable>(_ session: T) {
        guard session.isRunning else { return }

        session.removeAudioInput()
        session.removeMovieInput()
        session.stopRunning()
        
        Logger.log(message: "Session is terminated successfully")
    }
}
