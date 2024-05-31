//
//  ViewController.swift
//  CameraExampleApp
//
//  Created by Vishal Bhargava on 30/05/24.
//

import UIKit
import SwiftUI
import Combine

class GenericCameraController: UIViewController {

    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addAsAChild()
    }


    @IBAction func openCameraPressed(_ sender: Any) {
//        let pgCameraController = PGCameraController()
//        
//        pgCameraController.publisher.sink { [weak self] event in
//            switch event {
//            case .cancel:
//               debugPrint("Cancel Pressed")
//                pgCameraController.dismiss(animated: false) {
//                    
//                }
//            case .done(let arrCapturePhotos):
//                debugPrint("Done Pressed")
//                pgCameraController.dismiss(animated: false) {
//                    
//                }
//                
//            }
//        }.store(in: &cancellables)
//        
//        self.present(pgCameraController, animated: false, completion: nil)
    }
    
    // display the measure view as a view controller child
    private func addAsAChild(){
        let hostingViewController = HostingController(rootView: VideoContentView())
        addChildWithView(hostingViewController)
    }
}

extension GenericCameraController{
   func addChildWithView(_ child: UIViewController){
       addChild(child)
       view.addSubview(child.view)
       //child.view.frame = self.view.frame
       child.view.translatesAutoresizingMaskIntoConstraints = false
       child.view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
       child.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
       child.view.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
       child.view.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
       
       child.didMove(toParent: self)
   }
   
   func removeChildWithView(_ child: UIViewController){
       child.willMove(toParent: nil)
       child.removeFromParent()
       child.view.removeFromSuperview()
   }
}


class HostingController: UIHostingController<VideoContentView> {
    
}
