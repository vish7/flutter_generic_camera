//
//  AVFoundation + Extension.swift
//  
//
//  Created by Young Bin on 2024/05/28.
//

import AVFoundation

extension AVCaptureDevice.Position {
    var chooseBestCamera: AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera,
                                                                              .builtInTripleCamera,
                                                                              .builtInWideAngleCamera,
                                                                              .builtInUltraWideCamera],
                                                                mediaType: .video,
                                                                position: self)
        
        //Sort the devices by resolution
        let sortedDevices = discoverySession.devices.sorted { (device1, device2) -> Bool in
            guard let maxResolution1 = device1.maxResolution,
                  let maxResolution2 = device2.maxResolution else {
                return false
            }
            return maxResolution1 > maxResolution2
        }

        // First, seek a device with both the preferred position and device type. Otherwise, seek a device with only the preferred position.
        if let device = sortedDevices.first(where: { $0.position == self && $0.deviceType == .builtInUltraWideCamera }) {
            return device
        } else {
            return sortedDevices.first
        }
    }
    
    /// Property to determine if current device has Ultra Wide camera.
    var hasuWideCamera: Bool {
        let frontDevices = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: self)
        return (frontDevices != nil)
    }
    
}

import UIKit

extension AVCapturePhoto {
    var image: UIImage? {
        guard let imageData = fileDataRepresentation() else { return nil }
        return UIImage(data: imageData)
    }
}
