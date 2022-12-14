class NativeImageCropperException implements Exception {
  NativeImageCropperException(this.code, this.description);

  String code;
  String? description;

  @override
  String toString() => 'NativeImageCropperException($code, $description)';
}
