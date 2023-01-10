import Flutter

public class SwiftNativeImageCropperPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "biz.cosee/native_image_cropper_ios", binaryMessenger: registrar.messenger())
    let instance = SwiftNativeImageCropperPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("Test")
  }
}
