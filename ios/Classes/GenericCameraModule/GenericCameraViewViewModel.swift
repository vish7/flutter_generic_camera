//
//  VideoContentViewModel.swift
//  XCam-iOS
//
//  Created by Vishal on 2024/06/07.
//

import Combine
import SwiftUI
import Foundation
import AVFoundation


struct GenericCameraResult {
    let event: CameraActionEvent
    let images: [UIImage]?
    let videoFile : URL?
}

enum CameraActionEvent{
    case donePressed
    case closePressed
    case capturedVideo
    case capturedPhoto
}

struct GenericCameraConfiguation {
    var captureMode: AssetType =  .photo
    var canCaputreMultiplePhotos: Bool = false
    var cameraPosition: AVCaptureDevice.Position = .back
    var cameraPhotoFlash :  AVCaptureDevice.FlashMode = .auto
    var cameraVideoTorch :  AVCaptureDevice.TorchMode = .auto
}


class GenericCameraViewViewModel: ObservableObject {
    let xCamSession: XCamSession
    
    var preview: some View {
        xCamSession.interactivePreview()
        
        // Or you can give some options
//        let option = InteractivePreviewOption(enableZoom: true)
//        return xCamSession.interactivePreview(option: option)
    }
    
    private var subscription = Set<AnyCancellable>()
    
    @Published var videoAlbumCover: Image?
    @Published var photoAlbumCover: Image?
    
//    @Published var videoFiles: [VideoAsset] = []
//    @Published var photoFiles: [PhotoAsset] = []
    
    @Published var videoFiles: [VideoAsset] = []
    @Published var photoFiles: [UIImage] = []
    
    @State var captureMode: AssetType
    
    @Published var currentTime: String = "00:00"
    
    @Published var shouldSendData: Bool = false
    @Published var canCaputreMultiplePhotos : Bool
    
    @Published var videoCameraTourch : AVCaptureDevice.TorchMode
    
    private var timer: Timer?
    private var totalSeconds = 0

    
    public var cameraEventSubject = PassthroughSubject<GenericCameraResult, Never>()
    
    
    init(genericCameraConfiguration: GenericCameraConfiguation) {
        
        // If you don't want to make an album, you can set `albumName` to `nil`
        let option = XCamOption(albumName: nil)
        self.xCamSession = XCam.session(with: option)

        canCaputreMultiplePhotos =  genericCameraConfiguration.canCaputreMultiplePhotos;
        captureMode = genericCameraConfiguration.captureMode
        videoCameraTourch = genericCameraConfiguration.cameraVideoTorch
       
        
        
        // Common setting
        xCamSession
            //.common(.focus(mode: .continuousAutoFocus))
            .common(.changeMonitoring(enabled: true))
            .common(.orientation(orientation: .portrait))
            .common(.quality(preset: .high))
            .common(.custom(tuner: WideColorCameraTuner())) { result in
                if case .failure(let error) = result {
                    print("Error: ", error)
                }
            }
        
        // Photo-only setting
        xCamSession
            .photo(.flashMode(mode: genericCameraConfiguration.cameraPhotoFlash))
            .photo(.redEyeReduction(enabled: true))

        // Video-only setting
        xCamSession
            .video(.torch(mode: genericCameraConfiguration.cameraVideoTorch, level: 1.0))
            .video(.mute)
            .video(.stabilization(mode: .auto))

        // Prepare video album cover
        xCamSession.videoFilePublisher
            .receive(on: DispatchQueue.main)
            .map {result -> URL? in
                if case .success(let file) = result {
                    return file.path
                } else {
                    return nil
                }
            }
            .sink(receiveValue: { fileURL in
                debugPrint("Receive file url")
                self.cameraEventSubject.send(GenericCameraResult(event: .capturedVideo, images: nil, videoFile: fileURL))
//                if self.shouldSendData {
//                    self.xCamSession.terminateSession({ result in
//                        self.cameraEventSubject.send(GenericCameraResult(event: .capturedVideo, images: nil, videoFile: fileURL))
//                        debugPrint("Receive file url")
//                        
//                    })
//                }
                
            })
            .store(in: &subscription)
        
        // Prepare photo album cover
        xCamSession.photoFilePublisher
            .receive(on: DispatchQueue.main)
            .map { result -> UIImage? in
                if case .success(let file) = result {
                    return file.image
                } else {
                    return nil
                }
            }
            .sink(receiveValue: { image in
                if let imageObj = image {
                    self.photoAlbumCover = Image(uiImage: imageObj)
                    self.photoFiles.append(imageObj)
                }
                
                if self.canCaputreMultiplePhotos == false {
                     self.xCamSession.terminateSession({ result in
                         self.cameraEventSubject.send(GenericCameraResult(event: .capturedPhoto, images: self.photoFiles , videoFile: nil))
                    })
                }
            })
            //.assign(to: \.photoAlbumCover, on: self)
            .store(in: &subscription)
        
        xCamSession.videoAssetEventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self else { return }
                
                if case .deleted = event {
                    self.fetchVideoFiles()
                    
                    // It works, but not recommended
                    // videoFiles.remove(assets)
                    
                    // Update thumbnail
                    self.videoAlbumCover = self.videoFiles.first?.thumbnailImage
                }
            }
            .store(in: &subscription)

//        xCamSession.photoAssetEventPublisher
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] event in
//                guard let self else { return }
//
//                if case .deleted = event {
//                    self.fetchPhotoFiles()
//
//                    // It works, but not recommended
//                    // photoFiles.remove(assets)
//
//                    // Update thumbnail
//                    self.photoAlbumCover = self.photoFiles.first?.image
//                }
//            }
//            .store(in: &subscription)
        
        
        xCamSession.common(.position(position: genericCameraConfiguration.cameraPosition))
    }
    
    func fetchVideoFiles() {
        // File fetching task can cause low reponsiveness when called from main thread
        Task(priority: .utility) {
            let fetchedFiles = await xCamSession.fetchVideoFiles()
            DispatchQueue.main.async { self.videoFiles = fetchedFiles }
        }
    }
    
//    func fetchPhotoFiles() {
//        // File fetching task can cause low reponsiveness when called from main thread
//        Task(priority: .utility) {
//            let fetchedFiles = await xCamSession.fetchPhotoFiles()
//            DispatchQueue.main.async { self.photoFiles = fetchedFiles }
//        }
//    }
    
    func startTimer() {
        // Invalidate the previous timer if it exists
        timer?.invalidate()

        totalSeconds = 0  // Reset the timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.totalSeconds += 1
            self.updateTimeString()
        }
    }

    private func updateTimeString() {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        self.currentTime = String(format: "%02d:%02d", minutes, seconds)
    }
    
    func stopTimer() {
        self.currentTime = "00:00"
        timer?.invalidate()
    }
}


extension GenericCameraViewViewModel {
    // Example for using custom session tuner
    struct WideColorCameraTuner: XCamSessionTuning {
        func tune<T>(_ session: T) throws where T : XCamCoreSessionRepresentable {
            session.avCaptureSession.automaticallyConfiguresCaptureDeviceForWideColor = true
        }
    }
}
