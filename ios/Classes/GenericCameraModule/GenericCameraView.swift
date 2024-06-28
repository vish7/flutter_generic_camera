//
//  VideoContentView.swift
//  XCam-iOS
//
//  Created by Vishal on 2024/06/07.
//


import SwiftUI
import Combine




struct GenericCameraView: View {
    @State var isRecording = false
    @State var isFront = false
    
    @State var showSetting = false
    @State var showGallery = false
    
    @ObservedObject var viewModel: GenericCameraViewViewModel
    
    
    var doneButton: some View {
        VStack(alignment: .center) {
            Button(action: {
                viewModel.cameraEventSubject.send(GenericCameraResult(event: .donePressed, images: viewModel.photoFiles ,videoFile: nil))
            }, label: {
                Text("Done")
                    
                .foregroundColor(.white)
                .frame(width: 60,height: 30)
                .overlay(
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(Color.white, lineWidth: 1) // Add border to the button
                )
                    
                   
            })
            
        }.frame(width: 60,height: 60)
        .padding(EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 20))
    }
    
    var closeButton: some View {
        Button(action: {
            viewModel.cameraEventSubject.send(GenericCameraResult(event: .closePressed, images: nil,videoFile: nil))
        }, label: {
            Text("Close")
            .foregroundColor(.white)
            .frame(width: 60,height: 30)
               
        }).padding(EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 5))
    }
    
    var body: some View {
        ZStack {
            VStack{
                ZStack (alignment:.center){
                    HStack {
                        if !isRecording{
                            Button(action: { showSetting.toggle() }) {
                                Image("hamburger_menu", bundle: Bundle.main)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)

                            }
                            .padding(20)
                            Spacer()
                            closeButton
                        }
                       
                    }.frame(maxHeight: 40)
                    
                    
                    if viewModel.captureMode == .video {
                        
                        ZStack {
                            if viewModel.xCamSession.isRecording {
                                RoundedRectangle(cornerRadius: 2) // RoundedRectangle with 25-point corner radius
                                    .fill(Color.red)
                            }
                            Text(viewModel.currentTime)
                                .foregroundColor(.white)
                       }
                        .frame(width: 60, height: 30)
                    }
                   
                }
               
                
                ZStack (alignment: .topLeading){
                    viewModel.preview
                        .frame(minWidth: 0,
                               maxWidth: .infinity,
                               minHeight: 0,
                           maxHeight: .infinity)
                    
                    if (showSetting){
                        SettingView(contentViewModel: viewModel).frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,maxHeight: viewModel.captureMode == .video ? 370 : 300)
                    }
                }
                   
                
                VStack(alignment:.center,spacing: (viewModel.captureMode == .photo && viewModel.canCaputreMultiplePhotos) ? 0 : 15) {
                    //Spacer()
                    Text(viewModel.captureMode == .photo ? "Photo" : "Video")
                        .font(.title3)
                    .foregroundColor(.white)
                    //.background(Color.yellow)
                    
                    ZStack {
                        if viewModel.captureMode == .photo  && viewModel.canCaputreMultiplePhotos{
                            HStack {
                                // Album thumbnail + button
                                Button(action: { 
                                       showGallery = true
                                }) {
                                    let coverImage = (
                                        viewModel.captureMode == .video
                                        ? viewModel.videoAlbumCover
                                        : viewModel.photoAlbumCover)
                                    ?? Image("image_thumbnail")

                                    roundRectangleShape(with: coverImage, size: 60)
                                }
                                .shadow(radius: 5)
                                .contentShape(Rectangle())

                                Spacer()
                                
                                if viewModel.photoAlbumCover != nil {
                                    doneButton
                                }
                            }
                        }
                        
                            
                        VStack(alignment:.center,spacing: 0) {
                            recordingButtonShape(width: 70).onTapGesture {
                                viewModel.shouldSendData = true
                                switch viewModel.captureMode {
                                case .video:
                                    if isRecording {
                                        viewModel.stopTimer()
                                        viewModel.xCamSession.stopRecording()
                                        isRecording = false
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                                            self.viewModel.cameraEventSubject.send(GenericCameraResult(event: .closePressed, images: nil, videoFile: nil))
                                        })
                                    } else {
                                        viewModel.startTimer()
                                        viewModel.xCamSession.startRecording(autoVideoOrientationEnabled: true)
                                        isRecording = true
                                    }
                                case .photo:
                                    viewModel.xCamSession.capturePhoto(autoVideoOrientationEnabled: true)
                                    if !viewModel.canCaputreMultiplePhotos {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                                            self.viewModel.cameraEventSubject.send(GenericCameraResult(event: .closePressed, images: nil, videoFile: nil))
                                        })
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(maxHeight: 90)
            }
        }
    }
}

extension GenericCameraView {
    @ViewBuilder
    func roundRectangleShape(with image: Image, size: CGFloat) -> some View {
        image
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size, alignment: .center)
            .clipped()
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.white, lineWidth: 1)
            )
            .padding(20)
    }
    
    @ViewBuilder
    func recordingButtonShape(width: CGFloat) -> some View {
        ZStack {
            Circle()
                .strokeBorder(isRecording ? .red : .white, lineWidth: 3)
                .frame(width: width)
            
            Circle()
                .fill(isRecording ? .red : .white)
                .frame(width: width * 0.8)
        }
        .frame(height: width)
    }
}

enum AssetType {
    case video
    case photo
}

struct GenericCameraView_Previews: PreviewProvider {
    static var previews: some View {
        let config = GenericCameraConfiguation(captureMode: .photo,canCaputreMultiplePhotos: false, cameraPosition: .back,cameraPhotoFlash: .auto,cameraVideoTorch: .off)
        GenericCameraView(viewModel: GenericCameraViewViewModel(genericCameraConfiguration: config))
    }
}
