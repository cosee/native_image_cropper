/// Represents the image file format. It is used to decide how the image
/// should be compressed.
enum ImageFormat {
  /// Compress the image using JPG, which is usually faster.
  jpg,

  /// Compress the image using PNG, which is lossless but slower.
  png,
}
