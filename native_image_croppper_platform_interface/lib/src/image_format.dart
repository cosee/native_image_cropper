/// Represents the image file format. It is used to decide how the image
/// should be compressed.
enum ImageFormat {
  /// Compress the image using jpg, which is usually faster.
  jpg,

  /// Compress the image using png, which is lossless but slower.
  png,
}
