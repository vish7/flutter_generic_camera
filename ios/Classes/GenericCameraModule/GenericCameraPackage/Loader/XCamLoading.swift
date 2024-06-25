//
//  XCamAssetLoading.swift
//  
//
//  Created by Vishal on 2024/07/02.
//

import Foundation

protocol XCamAssetLoading {
    associatedtype ReturnType
    
    func loadAssets<Library, Collection>(_ library: Library, _ collection: Collection) throws -> ReturnType
    where Library: XCamAssetLibraryRepresentable,
          Collection: XCamAssetCollectionRepresentable
}
