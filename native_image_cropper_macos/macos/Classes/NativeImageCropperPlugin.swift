import Cocoa
import FlutterMacOS

public class NativeImageCropperPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "biz.cosee/native_image_cropper_macos", binaryMessenger: registrar.messenger)
        let instance = NativeImageCropperPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
            case "cropOval":
                handleCropOval(call, result)
            case "cropRect":
                handleCropRect(call, result)
            default:
                result(FlutterMethodNotImplemented)
        }
    }
    
    /// Extracts the arguments from [call] and crops the image in an oval shape.
    private func handleCropOval(_ call: FlutterMethodCall,_ result: @escaping FlutterResult) {
        DispatchQueue.main.async {
            do {
                let args = call.arguments as! [String: Any]
                let bytes = args["bytes"] as! FlutterStandardTypedData
                let x = args["x"] as! Int
                let y = args["y"] as! Int
                let width = args["width"] as! Int
                let height = args["height"] as! Int
                let imageFormat = ImageFormat(rawValue: (args["imageFormat"] as! String).uppercased())!
                
                let image = try self.flutterStandardTypeDataToNSImage(bytes: bytes)
                let croppedImage = try self.getCroppedRectNSImage(image: image, x: x, y: y, width: width, height: height)
                let croppedBytes = try self.nsImageToFlutterStandardTypeData(image: croppedImage, format: imageFormat)
                result(croppedBytes)
            } catch {
                result(FlutterError.init(code: String(describing: error.self), message: error.localizedDescription, details:nil))
            }
        }
    }
    
    /// Extracts the arguments from [call] and crops the image in a rectangular shape.
    private func handleCropRect(_ call: FlutterMethodCall,_ result: @escaping FlutterResult) {
        DispatchQueue.main.async {
            do {
                let args = call.arguments as! [String: Any]
                let bytes = args["bytes"] as! FlutterStandardTypedData
                let x = args["x"] as! Int
                let y = args["y"] as! Int
                let width = args["width"] as! Int
                let height = args["height"] as! Int
                let imageFormat = ImageFormat(rawValue: (args["imageFormat"] as! String).uppercased())!
                
                let image = try self.flutterStandardTypeDataToNSImage(bytes: bytes)
                let croppedImage = try self.getCroppedRectNSImage(image: image, x: x, y: y, width: width, height: height)
                let croppedBytes = try self.nsImageToFlutterStandardTypeData(image: croppedImage, format: imageFormat)
                result(croppedBytes)
            } catch {
                result(FlutterError.init(code: String(describing: error.self), message: error.localizedDescription, details:nil))
            }
        }
    }
    
    /// Creates an oval cropped [UIImage].
    private func getCroppedOvalNSImage(image: NSImage, x: Int, y: Int, width: Int, height: Int) throws -> NSImage {
       return image
    }
    
    /// Creates a rectangular cropped [NSImage].
    private func getCroppedRectNSImage(image: NSImage, x: Int, y: Int, width: Int, height: Int) throws -> NSImage {
        let cropRect = CGRect(x: x, y: y, width: width, height: height).integral
        let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)
        let croppedCgImage = cgImage?.cropping(to: cropRect)
        guard let croppedCgImage  = cgImage?.cropping(to: cropRect) else {
            throw NativeImageCropperError.cgImageNullError
        }
        
        return NSImage(cgImage: croppedCgImage, size: NSSize(width: width, height: height))
    }
    
    /// Converts a [FlutterStandardTypedData] to a [NSImage].
    private func flutterStandardTypeDataToNSImage(bytes: FlutterStandardTypedData) throws -> NSImage  {
        guard let image = NSImage(data: bytes.data) else {
            throw NativeImageCropperError.flutterStandardTypeDataToNSImageError
        }
        
        return image
    }
    
    /// Converts a [NSImage] to a [FlutterStandardTypedData].
    private func nsImageToFlutterStandardTypeData(image: NSImage, format: ImageFormat) throws -> FlutterStandardTypedData {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw NativeImageCropperError.cgImageNullError
        }
        
        let fileType: NSBitmapImageRep.FileType
        if case .JPG = format {
            fileType = NSBitmapImageRep.FileType.jpeg
        } else {
            fileType = NSBitmapImageRep.FileType.png
        }
        
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        guard let bytes = bitmapRep.representation(using: fileType, properties: [:]) else {
            throw NativeImageCropperError.dataNullError
        }
        
        return FlutterStandardTypedData(bytes: bytes)
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
    case flutterStandardTypeDataToNSImageError
    case nsImageToFlutterStandardTypeDataError
    case cgImageNullError
    case dataNullError
}


extension NativeImageCropperError {
    public var errorDescription: String?{
        switch self {
            case .flutterStandardTypeDataToNSImageError:
                return "Could not convert FlutterStandardTypeData to NSImage."
            case .nsImageToFlutterStandardTypeDataError:
                return "Could not convert NSImage to FlutterStandartTypeData."
            case .cgImageNullError:
                return "Could not crop because CGImage is null."
            case .dataNullError:
                return "Could not crop because Data is null."
        }
    }
}
