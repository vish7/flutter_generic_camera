//
//  VideoAssetAdditionProcessor.swift
//  
//
//  Created by Vishal on 2024/06/10.
//

import Photos
import Foundation

struct VideoAssetAdditionProcessor: XCamAssetProcessing {
    let filePath: URL

    func process<
        T: XCamAssetLibraryRepresentable, U: XCamAssetCollectionRepresentable
    >(
        _ photoLibrary: T,
        _ assetCollection: U
    ) async throws {
        try await add(video: filePath, to: assetCollection, photoLibrary)
    }

    /// Add the video to the app's album roll
    func add<
        T: XCamAssetLibraryRepresentable, U: XCamAssetCollectionRepresentable
    >(video path: URL,
      to album: U,
      _ photoLibrary: T
    ) async throws {
        guard album.canAdd(video: path) else {
            throw XCamError.album(reason: .notVideoURL)
        }

        return try await photoLibrary.performChanges {
            guard
                let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: path),
                let placeholder = assetChangeRequest.placeholderForCreatedAsset,
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: album.underlyingAssetCollection)
            else {
                Logger.log(error: XCamError.album(reason: .unabledToAccess))
                return
            }

            let enumeration = NSArray(object: placeholder)
            albumChangeRequest.addAssets(enumeration)
            
            Logger.log(message: "File is added to album")
        }
    }
}
