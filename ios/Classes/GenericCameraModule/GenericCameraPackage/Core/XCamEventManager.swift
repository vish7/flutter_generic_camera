//
//  XCamEventManager.swift
//
//
//  Created by YoungBin Lee on 4/18/24.
//

import Foundation
import Combine

class XCamEventManager {
    let videoAssetEventPublihser = PassthroughSubject<AssetEvent, Never>()
    let photoAssetEventPublihser = PassthroughSubject<AssetEvent, Never>()
}
