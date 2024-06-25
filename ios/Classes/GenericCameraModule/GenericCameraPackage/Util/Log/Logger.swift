//
//  LoggingManager.swift
//  
//
//  Created by Young Bin on 2024/05/27.
//

import Foundation

class Logger {
    static var enableLogging = true

    static func log(message: String) {
        if enableLogging {
            print("[XCam] \(message)")
        }
    }

    static func log(
        error: Error,
        message: String = "",
        method: String = #function
    ) {
        if enableLogging {
            let timestamp = Date().description
            print(
                "[⚠️ XCam Error] \(timestamp) |" +
                " Method: \(method) |" +
                " Error: \(error) |" +
                " Description: \(error.localizedDescription) |" +
                (
                    message.isEmpty ? "" : " Message: \(message)"
                )
            )
        }
    }
}
