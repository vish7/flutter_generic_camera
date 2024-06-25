//
//  XCamTuning.swift
//  
//
//  Created by Young Bin on 2024/06/10.
//

import Combine
import Foundation
import AVFoundation

/// `XCamSessionTuning` defines a set of requirements for classes or structs that aim to adjust settings
/// for an `XCamCoreSessionRepresentable`.
///
/// - Warning: Do not `begin` or `commit` session change yourself. It can cause deadlock.
///     Instead, use `needTransaction` flag
public protocol XCamSessionTuning {
    /// Determines if a transaction is required for this particular tuning operation.
    /// Default is `true`, indicating a transaction is generally needed.
    var needTransaction: Bool { get }
    
    /// Applies the specific tuning implementation to a given `XCamCoreSessionRepresentable` session.
    /// It is expected that each concrete implementation of `XCamSessionTuning` will provide its own
    /// tuning adjustments here.
    ///
    /// - Parameter session: The `XCamCoreSessionRepresentable` session to be adjusted.
    ///
    /// - Throws: An error if any problems occur during the tuning process.
    func tune<T: XCamCoreSessionRepresentable>(_ session: T) throws
}

/// Default implementation for `XCamSessionTuning`.
public extension XCamSessionTuning {
    /// By default, tuning operations need a transaction. This can be overridden by specific tuners
    /// if a transaction isn't necessary for their operation.
    var needTransaction: Bool { true }
}

/// XCamConnectionTuning
protocol XCamConnectionTuning {
    func tune<T: XCamCaptureConnectionRepresentable>(_ connection: T) throws
}

/// - Warning: Do not `lock` or `release` device yourself. It can cause deadlock.
///     Instead, use `needLock` flag
protocol XCamDeviceTuning {
    var needLock: Bool { get }
    func tune<T: XCamCaptureDeviceRepresentable>(_ device: T) throws
}

extension XCamDeviceTuning {
    var needLock: Bool { true }
}
