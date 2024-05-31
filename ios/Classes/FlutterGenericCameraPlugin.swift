import Flutter
import UIKit

public class FlutterGenericCameraPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_generic_camera", binaryMessenger: registrar.messenger())
    let instance = FlutterGenericCameraPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "openCamera":
      if let viewController = UIApplication.shared.delegate?.window??.rootViewController {
        let cameraViewController = GenericCameraController()
        cameraViewController.modalPresentationStyle = .fullScreen
        viewController.present(cameraViewController, animated: true, completion: nil)
        result([:])
      } else {
        result(FlutterError(code: "UNAVAILABLE", message: "Root view controller not available", details: nil))
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
