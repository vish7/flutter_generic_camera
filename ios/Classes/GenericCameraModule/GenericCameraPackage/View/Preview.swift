//
//  File.swift
//  
//
//  Created by Young Bin on 2024/06/30.
//

import SwiftUI
import Foundation
import AVFoundation

struct Preview: UIViewControllerRepresentable {
    let session: XCamSession
    let gravity: AVLayerVideoGravity
    let previewLayer: AVCaptureVideoPreviewLayer
    
    init(
        of session: XCamSession,
        gravity: AVLayerVideoGravity
    ) {
        self.gravity = gravity
        self.session = session
        self.previewLayer = session.previewLayer
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .clear
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        previewLayer.videoGravity = gravity
        uiViewController.view.layer.addSublayer(previewLayer)
        
        debugPrint("Height Of Controller \( uiViewController.view.bounds) \(uiViewController.view.safeAreaInsets.top)");
        
        previewLayer.frame = CGRectMake(0, 0,  uiViewController.view.bounds.width,  uiViewController.view.bounds.height - (150 + 90))
        //previewLayer.frame = uiViewController.view.bounds
    }
    
    func dismantleUIViewController(_ uiViewController: UIViewController, coordinator: ()) {
        previewLayer.removeFromSuperlayer()
    }
}
