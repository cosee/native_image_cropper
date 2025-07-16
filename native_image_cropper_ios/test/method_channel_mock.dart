import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class MethodChannelMock {
  MethodChannelMock({
    required this.methods,
  }) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, _handler);
  }

  final Map<String, dynamic> methods;
  final MethodChannel methodChannel = const MethodChannel(
    'biz.cosee/native_image_cropper_ios',
  );
  final List<MethodCall> log = [];

  Future<Object?> _handler(MethodCall methodCall) {
    log.add(methodCall);
    if (!methods.containsKey(methodCall.method)) {
      throw MissingPluginException(
        'No implementation found for method '
        '${methodCall.method} on channel ${methodChannel.name}',
      );
    }
    final result = methods[methodCall.method];
    if (result is Exception) {
      throw result;
    }

    return Future.value(result);
  }
}
