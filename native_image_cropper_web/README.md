# native_image_cropper_web

The Web implementation of [`native_image_cropper`][native_image_cropper].

## Usage

This package is [endorsed][endorsed], which means you can simply use `native_image_cropper`
normally. This package will be automatically included in your app when you do.

# Limitations on the web platform

The Flutter engine Skia does not support JPEG. Therefore, our package currently only supports
cropping to PNG format. On the web platform, isolates are [not supported][concurrency_web] for
concurrency, which means that the UI may freeze for large images.<br>
However, we plan to implement a solution for JPEG support in the future, and we will also look into
utilizing [web workers][web_workers] to run scripts in background threads, similar to isolates.

[concurrency_web]: https://dart.dev/language/concurrency#concurrency-on-the-web

[endorsed]: https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin

[native_image_cropper]: https://pub.dev/packages/native_image_cropper

[web_workers]: https://developer.mozilla.org/en-US/docs/Web/API/Web_Workers_API/Using_web_workers