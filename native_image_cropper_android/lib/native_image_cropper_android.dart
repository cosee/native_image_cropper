import 'package:native_image_cropper_platform_interface/native_image_cropper_platform_interface.dart';

class NativeImageCropperAndroid extends MethodChannelNativeImageCropper {
  static void registerWith() {
    NativeImageCropperPlatform.instance = NativeImageCropperAndroid();
  }
}
