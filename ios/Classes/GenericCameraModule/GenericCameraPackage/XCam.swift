//
//  XCam.swift
//  
//
//  Created by Vishal on 2024/06/10.
//

/// Top-level class that serves as the main access point for video recording sessions.
open class XCam {
    /// The core `XCamSession` that manages the actual video recording session.
    private static var core: XCamSession?

    /// Creates a new `XCamSession` with the given options.
    ///
    /// - Parameters:
    ///   - option: The `XCamOption` to configure the session.
    /// - Returns: The newly created `XCamSession`.
    public static func session(
        with option: XCamOption,
        onComplete: @escaping CompletionHandler = { _ in }
    ) -> XCamSession {
        if let core { return core }
        
        let newCore = XCamSession(option: option)

        // Check logging option
        Logger.enableLogging = option.log.loggingEnabled
        
        // Configure session now
        Task {
            guard
                case .permitted = await AuthorizationChecker.checkCaptureAuthorizationStatus()
            else {
                throw XCamError.permission(reason: .denied)
            }
            
            newCore.startSession(onComplete)
        }
        
        core = newCore
        return newCore
    }
    
    /// Terminates the current `XCamSession`.
    ///
    /// If a session has been started, it stops the session and releases resources.
    /// After termination, a new session needs to be configured to start recording again.
    public static func terminate(_ onComplete: @escaping CompletionHandler = { _ in }) throws {
        guard let core = core else {
            return
        }

        core.terminateSession { result in
            self.core = nil
            onComplete(result)
        }
    }
}
