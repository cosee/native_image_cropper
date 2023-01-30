# native_image_cropper

A Flutter plugin which supports native rectangular and circular cropping.

![Preview example](example/screenshots/example.gif "Example")

## Features

* Better performance, since it is written in Kotlin/Swift
* Usable without widget
* Rectangular and circular cropping
* Customizable drag points
* Customizable crop layer
* Customizable hit size

## Usage

Depend on it:

```yaml
dependencies:
  native_imager_cropper: ^0.1.0
```

Import it:

```dart
import 'package:native_imager_cropper/native_image_cropper.dart';
```

## Example

```dart
Scaffold(
  body: CropPreview(
    bytes: imageData,
  ),
);
```

## Customization options:

```dart

final maskOptions = const MaskOptions(
  backgroundColor: Colors.black38,
  borderColor: Colors.grey,
  strokeWidth: 2,
  aspectRatio: 4 / 3,
  minSize: 0,
);

CropPreview(
  mode: CropMode.rect,
  dragPointSize: 20,
  hitSize: 20,
  maskOptions: maskOptions,
  dragPointBuilder: (size, position) {
    if (position == CropDragPointPosition.topLeft) {
      return CropDragPoint(size: size, color: Colors.red);
    }
    return CropDragPoint(size: size, color: Colors.blue);
  },
);
```

## Crop an image

To crop an image you can pass a `CropController` to `CropPreview`:

```dart

final controller = CropController();

CropPreview(controller: controller, bytes: imageData);

final croppedImage = await controller.crop();
```

or call it directly using MethodChannel:

```dart
final croppedImage = await NativeImageCropper.cropRect(
  bytes: imageData,
  x: 0,
  y: 0,
  width: 500,
  height: 500,
);