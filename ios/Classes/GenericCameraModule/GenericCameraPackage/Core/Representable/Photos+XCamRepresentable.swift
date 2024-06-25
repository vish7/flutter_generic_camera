//
//  File.swift
//  
//
//  Created by Vishal on 2024/06/16.
//

import Photos
import Foundation

protocol XCamAssetLibraryRepresentable {
    func performChanges(_ changes: @escaping () -> Void) async throws
    func performChangesAndWait(_ changeBlock: @escaping () -> Void) throws
    func requestAuthorization(for accessLevel: PHAccessLevel) async -> PHAuthorizationStatus
    
    func fetchAlbum<Collection: XCamAssetCollectionRepresentable>(
        title: String,
        fetchOptions: PHFetchOptions
    ) -> Collection?
}

protocol XCamAssetCollectionRepresentable {
    var underlyingAssetCollection: PHAssetCollection { get }
    var localizedTitle: String? { get }

    func canAdd(video filePath: URL) -> Bool
}

extension PHPhotoLibrary: XCamAssetLibraryRepresentable {
    func fetchAlbum<Collection: XCamAssetCollectionRepresentable>(
        title: String,
        fetchOptions: PHFetchOptions
    ) -> Collection? {
        fetchOptions.predicate = NSPredicate(format: "title = %@", title)
        let collections = PHAssetCollection.fetchAssetCollections(
            with: .album, subtype: .any, options: fetchOptions
        )

        return collections.firstObject as? Collection
    }
    
    func requestAuthorization(for accessLevel: PHAccessLevel) async -> PHAuthorizationStatus {
        await PHPhotoLibrary.requestAuthorization(for: accessLevel)
    }
}

extension PHAssetCollection: XCamAssetCollectionRepresentable {
    var underlyingAssetCollection: PHAssetCollection { self }

    func canAdd(video filePath: URL) -> Bool {
        let asset = AVAsset(url: filePath)
        let tracks = asset.tracks(withMediaType: AVMediaType.video)

        return !tracks.isEmpty
    }
}
