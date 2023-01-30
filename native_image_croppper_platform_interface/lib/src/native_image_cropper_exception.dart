/// This error is thrown when the plugin reports an error.
class NativeImageCropperException implements Exception {
  /// Create a new native_image_cropper exception with the given error code
  /// and description.
  const NativeImageCropperException(this.code, [this.description]);

  /// Error code.
  final String code;

  /// Textual description of the error.
  final String? description;

  @override
  String toString() => 'NativeImageCropperException($code, $description)';
}
