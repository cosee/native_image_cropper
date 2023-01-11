import Flutter

public class SwiftNativeImageCropperPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "biz.cosee/native_image_cropper_ios", binaryMessenger: registrar.messenger())
        let instance = SwiftNativeImageCropperPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
            case "cropCircle":
                handleCropCircle(call,  result)
            case "cropRect":
                handleCropRect(call,  result)
            default:
                result(FlutterMethodNotImplemented)
        }
    }
    
    private func handleCropRect(_ call: FlutterMethodCall,_ result: @escaping FlutterResult){
        DispatchQueue.main.async {
            do {
                let args = call.arguments as! [String: Any]
                let bytes = args["bytes"] as! FlutterStandardTypedData
                let x = args["x"] as! Int
                let y = args["y"] as! Int
                let width = args["width"] as! Int
                let height = args["height"] as! Int
                
                let image = try self.flutterStandardTypeDataToUIImage(bytes: bytes)
                let croppedImage = try self.getCroppedRectUIImage(image: image, x: x, y: y, width: width, height: height)
                let croppedBytes = try self.uiImageToFlutterStandardTypedData(image: croppedImage)
                result(croppedBytes)
            } catch {
                result(FlutterError.init(code: String(describing: error.self), message: error.localizedDescription, details:nil))
            }
        }
    }
    
    private func handleCropCircle(_ call: FlutterMethodCall,_ result: @escaping FlutterResult){
        DispatchQueue.main.async {
            do {
                let args = call.arguments as! [String: Any]
                let bytes = args["bytes"] as! FlutterStandardTypedData
                let x = args["x"] as! Int
                let y = args["y"] as! Int
                let width = args["width"] as! Int
                let height = args["height"] as! Int
                
                let image = try self.flutterStandardTypeDataToUIImage(bytes: bytes)
                let croppedImage = try self.getCroppedCircleUIImageimage(image: image, x: x, y: y, width: width, height: height)
                let croppedBytes = try self.uiImageToFlutterStandardTypedData(image: croppedImage)
                result(croppedBytes)
            } catch {
                result(FlutterError.init(code: String(describing: error.self), message: error.localizedDescription, details:nil))
            }
        }
    }
    
    private func uiImageToFlutterStandardTypedData(image: UIImage) throws -> FlutterStandardTypedData {
        let bytes = image.jpegData(compressionQuality: 1)
        if let bytes {
            return FlutterStandardTypedData(bytes: bytes)
        }
        // TODO: Raise error if nil
        return FlutterStandardTypedData(bytes: bytes!)
    }
    
    private func flutterStandardTypeDataToUIImage(bytes: FlutterStandardTypedData) throws -> UIImage{
        let image = UIImage(data: bytes.data)
        if let image {
            return image
        }
        // TODO Raise exception
        return image!
    }
    
    private func getCroppedRectUIImage(image: UIImage,x: Int, y: Int, width: Int, height: Int) throws -> UIImage {
        let cropRect = CGRect(x: x, y: y, width: width, height: height).integral
        let cgImage = image.cgImage
        let croppedCgImage = cgImage?.cropping(to: cropRect)
        if let croppedCgImage {
            return UIImage(
                cgImage: croppedCgImage,
                scale: image.imageRendererFormat.scale,
                orientation: image.imageOrientation
            )
        }
        // TODO throw exception
        return image
    }
    
    private func getCroppedCircleUIImageimage(image: UIImage, x: Int, y: Int, width: Int, height: Int) throws -> UIImage {
        let croppedRectImage = try getCroppedRectUIImage(image: image, x: x, y: y, width: width, height: height)
        
        // Ensure that the cropped image does not include a background fill
        let imageRendererFormat = image.imageRendererFormat
        imageRendererFormat.opaque = false
        
        let circleCroppedImage = UIGraphicsImageRenderer(
            size: croppedRectImage.size,
            format: imageRendererFormat).image { _ in
                let cropRect = CGRect(
                    origin: .zero,
                    size: croppedRectImage.size
                )
                
                // Draws the circle inside the cropRect
                UIBezierPath(ovalIn: cropRect).addClip()
                
                // Draws the image inside the circle
                croppedRectImage.draw(in: cropRect)
            }
        return circleCroppedImage
    }
}
