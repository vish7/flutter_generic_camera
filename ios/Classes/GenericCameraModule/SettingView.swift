//
//  SettingView.swift
//  XCam-iOS
//
//  Created by Young Bin on 2024/06/08.
//

import SwiftUI
import AVFoundation

struct SettingView: View {
    @ObservedObject var viewModel: GenericCameraViewViewModel

    @State private var quality: AVCaptureSession.Preset
    @State private var focusMode: AVCaptureDevice.FocusMode
    
    @State private var isMuted: Bool
    
    @State private var flashMode: AVCaptureDevice.FlashMode
    @State private var cameraPosition: AVCaptureDevice.Position
    
    @State private var cameraZoomFactor : Double
    
    @State private var torchMode: AVCaptureDevice.TorchMode
    
    init(contentViewModel viewModel: GenericCameraViewViewModel) {
        self.viewModel = viewModel
        
        self.quality = viewModel.xCamSession.avCaptureSession.sessionPreset
        self.focusMode = viewModel.xCamSession.currentFocusMode ?? .continuousAutoFocus
        
        self.isMuted = viewModel.xCamSession.isMuted
        
        self.flashMode = viewModel.xCamSession.currentSetting.flashMode
        
        self.cameraPosition =  viewModel.xCamSession.currentCameraPosition ?? .back
        
        
        self.torchMode = viewModel.videoCameraTourch
        
        self.cameraZoomFactor = viewModel.xCamSession.currentZoomFactor ?? 1.0
        
        debugPrint("Setting View Init \(self.cameraZoomFactor)")
        
    }
    
    var body: some View {
        VStack(spacing:30){
            
            if viewModel.captureMode == .photo {
                Picker("Flash", selection: $flashMode) {
                    Text("On").tag(AVCaptureDevice.FlashMode.on)
                    Text("Off").tag(AVCaptureDevice.FlashMode.off)
                    Text("Auto").tag(AVCaptureDevice.FlashMode.auto)
                }
                .modifier(TitledPicker(title: "Flash"))
                .onChange(of: flashMode) { newValue in
                    viewModel.xCamSession.photo(.flashMode(mode: newValue))
                }
            }else{
                Picker("Flash", selection: $torchMode) {
                    Text("On").tag(AVCaptureDevice.TorchMode.on)
                    Text("Off").tag(AVCaptureDevice.TorchMode.off)
                    Text("Auto").tag(AVCaptureDevice.TorchMode.auto)
                }
                .modifier(TitledPicker(title: "Flash"))
                .onChange(of: torchMode) { newValue in
                    viewModel.xCamSession.video(.torch(mode: newValue, level: 1.0))
                }
            }
            
            
            
            Picker("Camera", selection: $cameraPosition) {
                Text("Front").tag(AVCaptureDevice.Position.front)
                Text("Back").tag(AVCaptureDevice.Position.back)
            }
            .modifier(TitledPicker(title: "Camera"))
            .onChange(of: cameraPosition) { newValue in
                viewModel.xCamSession.common(.position(position: cameraPosition))
            }

            Picker("Zoom", selection: $cameraZoomFactor) {
                if cameraPosition.hasuWideCamera {
                    Text("0.5x").tag(1.0)
                    Text("1.0x").tag(2.0)
                    Text("2.0x").tag(4.0)
                }else{
                    Text("1.0x").tag(1.0)
                    Text("2.0x").tag(2.0)
                }
               
            }
            .modifier(TitledPicker(title: "Zoom"))
            .onChange(of: cameraZoomFactor) { newValue in
                viewModel.xCamSession.common(.zoom(factor: newValue))
            }
            
            if viewModel.captureMode == .video {
                Picker("Microphone", selection: $isMuted) {
                    Text("Unmute").tag(false)
                    Text("Mute").tag(true)
                }
                .modifier(TitledPicker(title: "Microphone"))
                .onChange(of: isMuted) { newValue in
                    viewModel.xCamSession.video(newValue ? .mute : .unmute)
                }
            }
            
            
            Spacer()
            
        }.padding(EdgeInsets.init(top: 10, leading: 20, bottom: 10, trailing: 20))
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.init(hex: "#000000"), Color.init(hex: "#737373")]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .edgesIgnoringSafeArea(.all)
        
        
    }
    
    struct TitledPicker: ViewModifier {
        let title: String
        func body(content: Content) -> some View {
            VStack(alignment: .leading) {
                Text(title)
                    .foregroundColor(.white)
                    .font(.caption)
                
                content
                    .pickerStyle(.segmented)
                    .frame(height: 30)
            }
        }
    }
}
