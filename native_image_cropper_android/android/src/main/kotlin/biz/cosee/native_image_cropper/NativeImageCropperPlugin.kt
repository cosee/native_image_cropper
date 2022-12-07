package biz.cosee.native_image_cropper_android

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** NativeImageCropperAndroidPlugin */
class NativeImageCropperPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel =
            MethodChannel(flutterPluginBinding.binaryMessenger, "native_image_cropper_android")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        val cropDimension

        when (call.method) {
            "cropRect" -> {
               handleCropRect(CropSettings.fromMap(call.arguments));
            }
                else -> result.notImplemented();
            }
        }

    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun handleCropRect(settings: CropSettings): ByteArray {
        val bitmap = BitmapFactory.decodeByteArray(settings.bytes, 0, settings.bytes.count())
        val croppedBitmap =
            Bitmap.createBitmap(
                bitmap,
                settings.x,
                settings.y,
                settings.width,
                settings.height,
                null,
                false
            )
        val stream = ByteArrayOutputStream()
        croppedBitmap.compress(Bitmap.CompressFormat.JPEG, 100, stream)
        return stream.toByteArray();
    }

    data class CropSettings(
        val bytes: ByteArray,
        val x: Int,
        val y: Int,
        val width: Int,
        val height: Int
    ) {
        companion object {
            fun fromMap(map: Map<String, Any>): CropSettings =
                CropSettings(
                    bytes = map["bytes"] as ByteArray,
                    x = map["x"] as Int,
                    y = map["y"] as Int,
                    width = map["width"] as Int,
                    height = map["height"] as Int
                )
        }
    }
