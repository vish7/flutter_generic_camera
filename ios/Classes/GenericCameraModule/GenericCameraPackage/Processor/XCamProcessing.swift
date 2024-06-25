//
//  XCamProcessing.swift
//  
//
//  Created by Vishal on 2024/06/10.
//

import Photos
import Foundation
import AVFoundation

protocol XCamCapturePhotoOutputProcessing {
    func process<T: XCamPhotoOutputRepresentable>(_ output: T) throws
}

protocol XCamMovieFileOutputProcessing {
    func process<T: XCamFileOutputRepresentable>(_ output: T) throws
}

protocol XCamAssetProcessing {
    func process<Library, Collection>(
        _ library: Library,
        _ collection: Collection
    ) async throws
    where Library: XCamAssetLibraryRepresentable,
          Collection: XCamAssetCollectionRepresentable
}

protocol XCamFileProcessing {
    func process(_ fileManager: FileManager) throws
}
