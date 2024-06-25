//
//  FileWritingProcessor.swift
//  
//
//  Created by Vishal on 2024/07/06.
//

import Foundation

struct FileWritingProcessor: XCamFileProcessing {
    let data: Data
    let path: URL
    
    func process(_ fileManager: FileManager) throws {
        // Check if the directory exists, if not, returns.
        guard !fileManager.fileExists(atPath: path.deletingLastPathComponent().absoluteString) else {
            throw XCamError.file(reason: .alreadyExist)
        }
        
        try data.write(to: path)
    }
}
