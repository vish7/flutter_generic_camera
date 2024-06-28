//
//  VideoAlbumProvider.swift
//  
//
//  Created by Young Bin on 2024/05/27.
//

import Foundation

import Photos
import UIKit

struct AlbumImporter {
    private static let lock = NSRecursiveLock()

    static func getAlbum<
        Library: XCamAssetLibraryRepresentable,
        Collection: XCamAssetCollectionRepresentable
    >(
        name: String,
        in photoLibrary: Library,
        retry: Bool = true,
        _ fetchOptions: PHFetchOptions = .init()
    ) throws -> Collection {
        lock.lock()
        defer { lock.unlock() }

        let album: Collection? = photoLibrary.fetchAlbum(title: name, fetchOptions: fetchOptions)

        if let album {
            return album
        } else if retry {
            try createAlbum(name: name, in: photoLibrary)
            return try getAlbum(name: name, in: photoLibrary, retry: false, fetchOptions)
        } else {
            throw XCamError.album(reason: .unabledToAccess)
        }
    }

    static private func createAlbum<Library: XCamAssetLibraryRepresentable>(
        name: String,
        in photoLibrary: Library
    ) throws {
        lock.lock()
        defer { lock.unlock() }

        try photoLibrary.performChangesAndWait {
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
        }
        
        Logger.log(message: "The album \(name) is created.")
    }
}
