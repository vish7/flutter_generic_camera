//
//  ViewController.swift
//  CameraExampleApp
//
//  Created by Vishal Bhargava on 30/05/24.
//

import UIKit
import SwiftUI
import Combine

protocol GenericCameraControllerDelegate: AnyObject {
    func capturedImagesPath(capturedImages: [String])
    func capturedVideoUrl(videoUrl : URL?)
}

class GenericCameraController: UIViewController {

    private var cancellables = Set<AnyCancellable>()
    weak var mDelegate : GenericCameraControllerDelegate?
    var configuration: GenericCameraConfiguation!

    override func viewDidLoad() {
        super.viewDidLoad()
        debugPrint("Hei")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addAsAChild()
    }
    
    deinit {
        cancellables.removeAll()
    }
    
    // display the measure view as a view controller child
    private func addAsAChild(){
        
        //let config = GenericCameraConfiguation(captureMode: .photo,canCaputreMultiplePhotos: true, cameraPosition: .back,cameraPhotoFlash: .off,cameraVideoTorch: .auto)
        
        let viewModel = GenericCameraViewViewModel(genericCameraConfiguration: configuration)
        let videoContentView = GenericCameraView(viewModel: viewModel)
        viewModel.cameraEventSubject
        .receive(on: DispatchQueue.main) // Ensure sink runs on main thread
        .sink(
            receiveCompletion: { completion in
                print("-- completion", completion)
                self.cancellables.first?.cancel()
                self.dismiss(animated: true)
                
            },
            receiveValue: {[weak self] result in
                viewModel.shouldSendData = false
                switch(result.event){
                case .closePressed:
                    viewModel.cameraEventSubject.send(completion: .finished)
                    debugPrint("Close Button Pressed")
                    break
                case .donePressed:
                    debugPrint("Done Button Pressed  \(result.images ?? [])")
                    viewModel.cameraEventSubject.send(completion: .finished)
                    let capturedImages = result.images ?? []
                    let arrImagePaths = self?.saveImages(images: capturedImages)
                    self?.mDelegate?.capturedImagesPath(capturedImages: arrImagePaths ?? [])
                    break;
                case .capturedPhoto:
                    debugPrint("capturedPhoto Button Pressed  \(result.images ?? [])")
                    let capturedImages = result.images ?? []
                    let arrImagePaths = self?.saveImages(images: capturedImages)
                    self?.mDelegate?.capturedImagesPath(capturedImages: arrImagePaths ?? [])
                    
                case .capturedVideo:
                    debugPrint("capturedVideo Button Pressed  \(result.videoFile ??  URL.init(string: "https://cameraxaapp.com")!)")
                    self?.mDelegate?.capturedVideoUrl(videoUrl: result.videoFile)
                    //viewModel.cameraEventSubject.send(completion: .finished)
                }
            }
        ).store(in: &cancellables)
        
        let hostingViewController = HostingController(rootView: videoContentView)
        addChildWithView(hostingViewController)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    func saveImage(image: UIImage, withName name: String) -> String? {
        guard let data = image.jpegData(compressionQuality: 1) else {
            print("Unable to convert image to data")
            return nil
        }

        let filename = getDocumentsDirectory().appendingPathComponent("\(name).jpg")
        do {
            try data.write(to: filename)
            return filename.path
        } catch {
            print("Unable to save image to disk: \(error)")
            return nil
        }
    }

    func saveImages(images: [UIImage]) -> [String] {
        var imagePaths: [String] = []

        for (index, image) in images.enumerated() {
            if let path = saveImage(image: image, withName: "image\(index)") {
                imagePaths.append(path)
            }
        }

        return imagePaths
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


class HostingController: UIHostingController<GenericCameraView> {
    
}
