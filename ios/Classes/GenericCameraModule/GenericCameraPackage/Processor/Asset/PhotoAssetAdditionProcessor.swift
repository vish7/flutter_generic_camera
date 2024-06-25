//
//  PhotoAssetAdditionProcessor.swift
//  
//
//  Created by Vishal on 2024/06/19.
//

import Photos
import Foundation

struct PhotoAssetAdditionProcessor: XCamAssetProcessing {
    let imageData: Data

    func process<
        Library: XCamAssetLibraryRepresentable, Collection: XCamAssetCollectionRepresentable
    >(
        _ photoLibrary: Library,
        _ assetCollection: Collection
    ) async throws {
        try await add(imageData: imageData, to: assetCollection, photoLibrary)
    }
    
    /// Add the photo to the app's album roll
    func add<
        T: XCamAssetLibraryRepresentable, U: XCamAssetCollectionRepresentable
    >(
        imageData: Data,
        to album: U,
        _ photoLibrary: T
    ) async throws {
        return try await photoLibrary.performChanges {
            // Request creating an asset from the image.
            let creationRequest = PHAssetCreationRequest.forAsset()
            creationRequest.addResource(with: .photo, data: imageData, options: nil)
            
            // Add the asset to the desired album.
            guard
                let placeholder = creationRequest.placeholderForCreatedAsset,
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: album.underlyingAssetCollection)
            else {
                Logger.log(error: XCamError.album(reason: .unabledToAccess))
                return
            }
            
            let enumeration = NSArray(object: placeholder)
            albumChangeRequest.addAssets(enumeration)
            
            Logger.log(message: "Photo is added to album")
        }
    }
}
