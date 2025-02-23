//
//  VideoRecorderError.swift
//  YellowIsTheNewBlack
//
//  Created by Vishal on 2022/06/07.
//

import Foundation

public enum XCamError: LocalizedError {
    case session(reason: SessionErrorReason)
    case device(reason: DeviceErrorReason)
    case permission(reason: PermissionErrorReason)
    case album(reason: AlbumErrorReason)
    case file(reason: FileErrorReason)
    case connection(reason: ConnectionErrorReason)


    public var errorDescription: String? {
        switch self {
        case .session(let reason):
            return reason.rawValue
        case .device(let reason):
            return reason.rawValue
        case .permission(let reason):
            return reason.rawValue
        case .album(let reason):
            return reason.rawValue
        case .file(let reason):
            return reason.rawValue
        case .connection(let reason):
            return reason.rawValue
        }
    }
}

public extension XCamError {
    enum SessionErrorReason: String {
        case notConfigured =
                "No camera session was created, please check your camera permissions."
        case notRunning =
                "Session is not running. Check if you've ran the session or permitted camera permissio.n"
        case cannnotFindMovieFileOutput =
                "Couldn't find connected output. Check if you've added connection properly"
        case cannotFindConnection =
                "Couldn't find connection. Check if you've added connection properly"
        case cannotFindDevice =
                "Couldn't find device. Check if you've added device properly"
    }

    enum DeviceErrorReason: String {
        case invalid =
                "Unable to set up camera device. Please check camera usage permission."
        case unableToSetInput =
                "Unable to set input."
        case outputAlreadyExists =
                "Output is already exists"
        case unableToSetOutput =
                "Unable to set output."
        case notSupported =
                "Unsupported functionality."
        case busy =
                "Device is busy now."
    }

    enum PermissionErrorReason: String {
        case denied =
                "Cannot take a video because camera permissions are denied."
    }

    enum AlbumErrorReason: String {
        case unabledToAccess =
                "Unable to access album"
        case videoNotExist =
                "Trying to delete or fetch the video that does not exist."
        case notVideoURL =
                "Received URL is not a video type."
    }

    enum FileErrorReason: String {
        case unableToFlatten =
                "Cannot take a video because camera permissions are denied."
        case notSupported =
                "Unsuportted file type."
        case alreadyExist =
                "File already exists. Cannot overwrite the file."
    }

    enum ConnectionErrorReason: String {
        case cannotChangeVideoOrientation =
                "Changing orientation is not supported currently. This behavior will be ignored."
    }
}
