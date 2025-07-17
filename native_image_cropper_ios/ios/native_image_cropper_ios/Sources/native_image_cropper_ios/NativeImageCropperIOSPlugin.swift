import Flutter

public class NativeImageCropperPlugin: NSObject, FlutterPlugin {
    /// Initializes a [MethodChannel], which is used to communicate between the Flutter code  and the native Swift code.
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "biz.cosee/native_image_cropper_ios", binaryMessenger: registrar.messenger())
        let instance = NativeImageCropperPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    /// Handles Flutter method calls made to this Flutter plugin.
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
            case "cropOval":
                handleCropOval(call,  result)
            case "cropRect":
                handleCropRect(call,  result)
            default:
                result(FlutterMethodNotImplemented)
        }
    }

    /// Extracts the arguments from [call] and crops the image in a rectangular shape.
    private func handleCropRect(_ call: FlutterMethodCall,_ result: @escaping FlutterResult){
        DispatchQueue.main.async {
            do {
                let args = call.arguments as! [String: Any]
                let bytes = args["bytes"] as! FlutterStandardTypedData
                let x = args["x"] as! Int
                let y = args["y"] as! Int
                let width = args["width"] as! Int
                let height = args["height"] as! Int
                let imageFormat = ImageFormat(rawValue: (args["imageFormat"] as! String).uppercased())!
                
                let image = try self.flutterStandardTypeDataToUIImage(bytes: bytes)
                let croppedImage = try self.getCroppedRectUIImage(image: image, x: x, y: y, width: width, height: height)
                let croppedBytes = try self.uiImageToFlutterStandardTypedData(image: croppedImage, format: imageFormat)
                result(croppedBytes)
            } catch {
                result(FlutterError.init(code: String(describing: error.self), message: error.localizedDescription, details:nil))
            }
        }
    }

    /// Extracts the arguments from [call] and crops the image in a oval shape.
    private func handleCropOval(_ call: FlutterMethodCall,_ result: @escaping FlutterResult){
        DispatchQueue.main.async {
            do {
                let args = call.arguments as! [String: Any]
                let bytes = args["bytes"] as! FlutterStandardTypedData
                let x = args["x"] as! Int
                let y = args["y"] as! Int
                let width = args["width"] as! Int
                let height = args["height"] as! Int
                let imageFormat = ImageFormat(rawValue: (args["imageFormat"] as! String).uppercased())!
                
                let image = try self.flutterStandardTypeDataToUIImage(bytes: bytes)
                let croppedImage = try self.getCroppedOvalUIImage(image: image, x: x, y: y, width: width, height: height)
                let croppedBytes = try self.uiImageToFlutterStandardTypedData(image: croppedImage, format: imageFormat)
                result(croppedBytes)
            } catch {
                result(FlutterError.init(code: String(describing: error.self), message: error.localizedDescription, details:nil))
            }
        }
    }

    /// Converts a [UIImage] to a [FlutterStandardTypedData] by using the given [format] for compression.
    private func uiImageToFlutterStandardTypedData(image: UIImage, format: ImageFormat) throws -> FlutterStandardTypedData {
        let bytes: Data?
        if case .JPG = format {
            bytes = image.jpegData(compressionQuality: 1)
        } else {
            bytes = image.pngData()
        }
        
        if let bytes {
            return FlutterStandardTypedData(bytes: bytes)
        }
        throw NativeImageCropperError.uIImageToFlutterStandardTypeDataError
    }

    /// Converts a [FlutterStandardTypedData] to a [UIImage].
    private func flutterStandardTypeDataToUIImage(bytes: FlutterStandardTypedData) throws -> UIImage{
        let image = UIImage(data: bytes.data)
        if let image {
            return image
        }
        throw NativeImageCropperError.flutterStandardTypeDataToUIImageError
    }

    /// Creates a rectangular cropped [UIImage].
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
        throw NativeImageCropperError.cgImageNullError
    }

    /// Creates an oval cropped [UIImage].
    private func getCroppedOvalUIImage(image: UIImage, x: Int, y: Int, width: Int, height: Int) throws -> UIImage {
        let croppedRectImage = try getCroppedRectUIImage(image: image, x: x, y: y, width: width, height: height)
        
        // Ensure that the cropped image does not include a background fill
        let imageRendererFormat = image.imageRendererFormat
        imageRendererFormat.opaque = false
        
        let ovalCroppedImage = UIGraphicsImageRenderer(
            size: croppedRectImage.size,
            format: imageRendererFormat).image { _ in
                let cropRect = CGRect(
                    origin: .zero,
                    size: croppedRectImage.size
                )
                
                // Draws the oval inside the cropRect
                UIBezierPath(ovalIn: cropRect).addClip()
                
                // Draws the image inside the oval
                croppedRectImage.draw(in: cropRect)
            }
        return ovalCroppedImage
    }

    ///  Represents the image file format. It is used to decide how the image should be compressed.
    enum ImageFormat: String {
        /// Compress the image using JPG, which is usually faster.
        case JPG = "JPG"

        /// Compress the image using PNG, which is lossless but slower.
        case PNG = "PNG"
    }
}

private enum NativeImageCropperError: LocalizedError {
    case flutterStandardTypeDataToUIImageError
    case uIImageToFlutterStandardTypeDataError
    case cgImageNullError
}

extension NativeImageCropperError {
    public var errorDescription: String?{
        switch self {
            case .flutterStandardTypeDataToUIImageError:
                return "Could not convert FlutterStandardTypeData to UIImage."
            case .uIImageToFlutterStandardTypeDataError:
                return "Could not convert UIImage to FlutterStandartTypeData."
            case .cgImageNullError:
                return "Could not crop because CGImage is null."
        }
    }
}
