//
//  XCamCoreSessionManager.swift
//  
//
//  Created by Vishal on 2024/06/10.
//

import UIKit
import Combine
import Foundation
import AVFoundation

class XCamCoreSession: AVCaptureSession {
    var option: XCamOption
    private var workQueue = OperationQueue()
    
    init(option: XCamOption) {
        self.option = option
        
        workQueue.qualityOfService = .background
        workQueue.maxConcurrentOperationCount = 1
        workQueue.isSuspended = true
    }
    
    func run<T: XCamSessionTuning>(_ tuner: T, _ onComplete: @escaping CompletionHandler) {
        workQueue.addOperation {
            do {
                if tuner.needTransaction { self.beginConfiguration() }
                defer {
                    if tuner.needTransaction { self.commitConfiguration() }
                    onComplete(.success(()))
                }
                
                try tuner.tune(self)
            } catch let error {
                Logger.log(error: error, message: "in \(tuner)")
                onComplete(.failure(error))
            }
        }
    }
    
    func run<T: XCamDeviceTuning>(_ tuner: T, _ onComplete: @escaping CompletionHandler) {
        workQueue.addOperation {
            do {
                guard let device = self.videoDeviceInput?.device else {
                    throw XCamError.device(reason: .invalid)
                }
                
                if tuner.needLock { try device.lockForConfiguration() }
                defer {
                    if tuner.needLock { device.unlockForConfiguration() }
                    onComplete(.success(()))
                }
                
                try tuner.tune(device)
            } catch let error {
                Logger.log(error: error, message: "in \(tuner)")
                onComplete(.failure(error))
            }
        }
    }
    
    func run<T: XCamConnectionTuning>(_ tuner: T, _ onComplete: @escaping CompletionHandler) {
        workQueue.addOperation {
            do {
                guard let connection = self.connections.first else {
                    throw XCamError.session(reason: .cannotFindConnection)
                }
                
                try tuner.tune(connection)
                onComplete(.success(()))
            } catch let error {
                Logger.log(error: error, message: "in \(tuner)")
                onComplete(.failure(error))
            }
        }
    }
    
    func run<T: XCamMovieFileOutputProcessing>(_ processor: T, _ onComplete: @escaping CompletionHandler) {
        workQueue.addOperation {
            do {
                guard let output = self.movieFileOutput else {
                    throw XCamError.session(reason: .cannotFindConnection)
                }
                
                try processor.process(output)
                onComplete(.success(()))
            } catch let error {
                Logger.log(error: error, message: "in \(processor)")
                onComplete(.failure(error))
            }
        }
    }
    
    func start() throws {
        let session = self
        
        guard session.isRunning == false else { return }

        try session.addMovieInput()
        try session.addMovieFileOutput()
        try session.addCapturePhotoOutput()
        session.startRunning()
        
        self.workQueue.isSuspended = false
        Logger.log(message: "Session is configured successfully")
    }
}
