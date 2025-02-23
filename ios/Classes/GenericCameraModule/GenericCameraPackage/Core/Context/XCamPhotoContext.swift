//
//  XCamPhotoContext.swift
//  
//
//  Created by Vishal on 2024/06/22.
//

import Combine
import Foundation
import AVFoundation

/// `XCamPhotoContext` is an open class that provides a context for photo capturing operations.
/// It has methods and properties to handle the photo capturing and settings.
open class XCamPhotoContext {
    private let coreSession: XCamCoreSession
    private let albumManager: XCamCoreAlbumManager
    private let option: XCamOption
    
    private let camera: XCamCoreCamera
    
    private var photoSetting: AVCapturePhotoSettings
    private let photoFileBufferSubject: CurrentValueSubject<Result<PhotoFile, Error>?, Never>
    
    init(
        coreSession: XCamCoreSession,
        camera: XCamCoreCamera,
        albumManager: XCamCoreAlbumManager,
        option: XCamOption
    ) {
        self.coreSession = coreSession
        self.camera = camera
        self.albumManager = albumManager
        self.option = option
        
        self.photoSetting = AVCapturePhotoSettings()
        self.photoFileBufferSubject = .init(nil)
        
        // Add first video file to buffer if it exists
        if option.asset.synchronizeWithLocalAlbum {
            Task(priority: .utility) {
                guard let firstPhotoAsset = await albumManager.fetchPhotoFile(limit: 1).first else {
                    return
                }
                
                photoFileBufferSubject.send(.success(firstPhotoAsset.toPhotoFile))
            }
        }
    }
}

extension XCamPhotoContext: PhotoContext {
    public var underlyingPhotoContext: XCamPhotoContext {
        self
    }
    
    public var photoFilePublisher: AnyPublisher<Result<PhotoFile, Error>, Never> {
        photoFileBufferSubject.handleEvents(receiveOutput: { status in
            if case .failure(let error) = status {
                Logger.log(error: error)
            }
        })
        .compactMap({ $0 })
        .eraseToAnyPublisher()
    }
    
    public var currentSetting: AVCapturePhotoSettings {
        photoSetting
    }
    
    public func capturePhoto(
        autoVideoOrientationEnabled: Bool = false,
        _ completionHandler: @escaping (Result<PhotoFile, Error>) -> Void
    ) {
        Task(priority: .utility) {
            do {
                let photoFile = try await self.capturePhotoWithError(autoVideoOrientationEnabled: autoVideoOrientationEnabled)
                completionHandler(.success(photoFile))
            } catch let error {
                Logger.log(error: error)
                completionHandler(.failure(error))
            }
        }
    }
    
    @discardableResult
    public func photo(
        _ photoContextOption: PhotoContextOption,
        onComplete: CompletionHandler? = nil
    ) -> XCamPhotoContext {
        let onComplete = onComplete ?? { _ in }
        
        switch photoContextOption {
        case .flashMode(let flashMode):
            photoSetting.flashMode = flashMode
        case .redEyeReduction(let enabled):
            photoSetting.isAutoRedEyeReductionEnabled = enabled
        case .custom(let aVCapturePhotoSettings):
            photoSetting = aVCapturePhotoSettings
        }
        
        onComplete(.success(()))
        return self
    }
    
    public func fetchPhotoFiles(limit: Int) async -> [PhotoAsset] {
        guard option.asset.synchronizeWithLocalAlbum else {
            Logger.log(
                message:
                    "'option.asset.synchronizeWithLocalAlbum' is set to false " +
                    "so no photos will be fetched from the local album. " +
                    "If you intended to fetch photos, " +
                    "please ensure 'option.asset.synchronizeWithLocalAlbum' is set to true."
            )
            return []
        }
        
        return await albumManager.fetchPhotoFile(limit: limit)
    }
}

private extension XCamPhotoContext {
    func capturePhotoWithError(autoVideoOrientationEnabled: Bool) async throws -> PhotoFile {
        let setting = AVCapturePhotoSettings(from: photoSetting)
        let capturePhoto = try await camera.capture(setting: setting, autoVideoOrientationEnabled: autoVideoOrientationEnabled)
        
        guard let rawPhotoData = capturePhoto.fileDataRepresentation() else {
            throw XCamError.file(reason: .unableToFlatten)
        }
        
        if option.asset.synchronizeWithLocalAlbum {
            // Register to album
            try await albumManager.addToAlbum(imageData: rawPhotoData)
        }
        
        let photoFile = PhotoFileGenerator.generate(
            data: rawPhotoData,
            date: Date())
        
        photoFileBufferSubject.send(.success(photoFile))
        return photoFile
    }
}

// MARK: - Deprecated methods
extension XCamPhotoContext {
    @available(*, deprecated, message: "Please use `photo` instead.")
    @discardableResult
    public func flashMode(to mode: AVCaptureDevice.FlashMode) -> XCamPhotoContext {
        photoSetting.flashMode = mode
        return self
    }
    
    @available(*, deprecated, message: "Please use `photo` instead.")
    @discardableResult
    public func redEyeReduction(enabled: Bool) -> XCamPhotoContext {
        photoSetting.isAutoRedEyeReductionEnabled = enabled
        return self
    }
    
    @available(*, deprecated, message: "Please use `photo` instead.")
    public func custom(_ setting: AVCapturePhotoSettings) -> XCamPhotoContext {
        photoSetting = setting
        return self
    }
}
