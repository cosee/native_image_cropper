
import 'native_image_cropper_web_platform_interface.dart';

class NativeImageCropperWeb {
  Future<String?> getPlatformVersion() {
    return NativeImageCropperWebPlatform.instance.getPlatformVersion();
  }
}
