import Flutter
import UIKit
import AVFoundation

public class FlutterGenericCameraPlugin: NSObject, FlutterPlugin {
    private var result: FlutterResult?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "flutter_generic_camera", binaryMessenger: registrar.messenger())
        let instance = FlutterGenericCameraPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      self.result = result
        switch call.method {
        case "openCamera":
            if let viewController = UIApplication.shared.delegate?.window??
                .rootViewController
            {
                if let args = call.arguments as? [String: Any],
                    let config = parseConfiguration(args: args) {
                    let cameraViewController = GenericCameraController()
                    cameraViewController.configuration = config
                    cameraViewController.mDelegate = self
                    cameraViewController.modalPresentationStyle = .fullScreen
                    viewController.present(
                        cameraViewController, animated: true, completion: nil)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments received", details: nil))
                }
                //result([:])
            } else {
                result(
                    FlutterError(
                        code: "UNAVAILABLE",
                        message: "Root view controller not available",
                        details: nil))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func parseConfiguration(args: [String: Any]) -> GenericCameraConfiguation? {
        guard let captureMode = args["captureMode"] as? Int,
              let canCaptureMultiplePhotos = args["canCaptureMultiplePhotos"] as? Bool,
              let cameraPosition = args["cameraPosition"] as? Int,
              let cameraPhotoFlash = args["cameraPhotoFlash"] as? Int,
              let cameraVideoTorch = args["cameraVideoTorch"] as? Int else {
            return nil
        }

        return GenericCameraConfiguation(
            captureMode: captureMode == 0 ? .photo : .video,
            canCaputreMultiplePhotos: canCaptureMultiplePhotos,
            cameraPosition: AVCaptureDevice.Position(rawValue: cameraPosition) ?? .back,
            cameraPhotoFlash: AVCaptureDevice.FlashMode(rawValue: cameraPhotoFlash) ?? .auto,
            cameraVideoTorch: AVCaptureDevice.TorchMode(rawValue: cameraVideoTorch) ?? .auto
        )
    }
}
extension FlutterGenericCameraPlugin: GenericCameraControllerDelegate {
    func capturedVideoUrl(videoUrl: URL?) {
        debugPrint("Captured Video Ready")
        if let url = videoUrl {
            self.result?(["captured_video":url.absoluteString]);
        }else{
            self.result?(["captured_video":""]);
        }
        
    }

    func capturedImagesPath(capturedImages: [String]) {
        debugPrint("Captured Images Ready")
        self.result?(["captured_images":capturedImages]);
    }
}
