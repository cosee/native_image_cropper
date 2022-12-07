import 'package:native_image_cropper_android/native_image_cropper_android_platform_interface.dart';

class NativeImageCropperAndroid {
  Future<String?> getPlatformVersion() {
    return NativeImageCropperAndroidPlatform.instance.getPlatformVersion();
  }
}
