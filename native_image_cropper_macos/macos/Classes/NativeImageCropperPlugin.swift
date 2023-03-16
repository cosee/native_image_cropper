import Cocoa
import FlutterMacOS

public class NativeImageCropperPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        NSLog("REGISTER")
        let channel = FlutterMethodChannel(name: "biz.cosee/native_image_cropper_macos", binaryMessenger: registrar.messenger)
        let instance = NativeImageCropperPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        NSLog("HANDLE")
        switch call.method {
            case "cropOval":
                NSLog("cropOval")
            case "cropRect":
                NSLog("CROP RECT")
                //handleCropRect(call, result)
            default:
              result(FlutterMethodNotImplemented)
        }
    }

    private func handleCropRect(_ call: FlutterMethodCall,_ result: @escaping FlutterResult) {
        NSLog("HANDLE RECT")
        do {
            let args = call.arguments as! [String: Any]
            let bytes = args["bytes"] as! FlutterStandardTypedData
            let x = args["x"] as! Int
            let y = args["y"] as! Int
            let width = args["width"] as! Int
            let height = args["height"] as! Int
            let imageFormat = ImageFormat(rawValue: (args["imageFormat"] as! String).uppercased())!

            print("X: ", x)
            print("Y: ", y)
            print("width: ", width)
            print("height: ", height)
            print("imageFormat: ", imageFormat)
            result(bytes)
        } catch {
           result(FlutterError.init(code: String(describing: error.self), message: error.localizedDescription, details:nil))
        }
    }

    ///  Represents the image file format. It is used to decide how the image should be compressed.
   enum ImageFormat: String {
       /// Compress the image using JPG, which is usually faster.
       case JPG = "JPG"

       /// Compress the image using PNG, which is lossless but slower.
       case PNG = "PNG"
   }
}
